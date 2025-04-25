import 'package:flutter/material.dart';
import 'package:novastate/novastate.dart';

class UserProfile {
  final String fullName;
  final int age;
  final Address address;
  final List<String> interests;
  final Map<String, bool> settings;

  const UserProfile({
    required this.fullName,
    required this.age,
    required this.address,
    required this.interests,
    required this.settings,
  });

  UserProfile copyWith({
    String? fullName,
    int? age,
    Address? address,
    List<String>? interests,
    Map<String, bool>? settings,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      address: address ?? this.address,
      interests: interests ?? this.interests,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'address': {
        'street': address.street,
        'city': address.city,
        'country': address.country,
      },
      'interests': interests,
      'settings': settings,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] as String,
      age: json['age'] as int,
      address: Address(
        street: json['address']['street'] as String,
        city: json['address']['city'] as String,
        country: json['address']['country'] as String,
      ),
      interests: (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      settings: Map<String, bool>.from(json['settings'] as Map),
    );
  }
}

class Address {
  final String street;
  final String city;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.country,
  });

  Address copyWith({
    String? street,
    String? city,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final Store<UserProfile> _profileStore;
  final TextEditingController _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('UserProfilePage: Initializing with default user profile');
    _profileStore = Store<UserProfile>(
      UserProfile(
        fullName: 'Nguyễn Văn A',
        age: 30,
        address: const Address(
          street: '123 Đường ABC',
          city: 'Hồ Chí Minh',
          country: 'Việt Nam',
        ),
        interests: ['Đọc sách', 'Du lịch', 'Công nghệ'],
        settings: {
          'enableNotifications': true,
          'darkMode': false,
          'autoSync': true,
        },
      ),
    );
  }

  @override
  void dispose() {
    _interestController.dispose();
    _profileStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateProvider<UserProfile>(
      store: _profileStore,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hồ sơ người dùng'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSection(
                title: 'Thông tin cơ bản',
                child: StateBuilder<UserProfile>(
                  builder: (context, profile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          label: 'Họ và tên',
                          initialValue: profile.fullName,
                          onChanged: (value) {
                            _profileStore.update((state) => 
                              state.copyWith(fullName: value)
                            );
                          },
                        ),
                        _buildTextField(
                          label: 'Tuổi',
                          initialValue: profile.age.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final age = int.tryParse(value);
                            if (age != null) {
                              _profileStore.update((state) => 
                                state.copyWith(age: age)
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              _buildSection(
                title: 'Địa chỉ',
                child: StateSelector<UserProfile, Address>(
                  selector: (profile) => profile.address,
                  builder: (context, address) {
                    print('UserProfilePage: Address section rebuilt - city: ${address.city}');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          label: 'Đường',
                          initialValue: address.street,
                          onChanged: (value) {
                            _profileStore.update((state) => 
                              state.copyWith(
                                address: state.address.copyWith(street: value)
                              )
                            );
                          },
                        ),
                        _buildTextField(
                          label: 'Thành phố',
                          initialValue: address.city,
                          onChanged: (value) {
                            _profileStore.update((state) => 
                              state.copyWith(
                                address: state.address.copyWith(city: value)
                              )
                            );
                          },
                        ),
                        _buildTextField(
                          label: 'Quốc gia',
                          initialValue: address.country,
                          onChanged: (value) {
                            _profileStore.update((state) => 
                              state.copyWith(
                                address: state.address.copyWith(country: value)
                              )
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              _buildSection(
                title: 'Sở thích',
                child: StateSelector<UserProfile, List<String>>(
                  selector: (profile) => profile.interests,
                  builder: (context, interests) {
                    print('UserProfilePage: Interests section rebuilt - count: ${interests.length}');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: interests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                _profileStore.update((state) {
                                  final newInterests = List<String>.from(state.interests);
                                  newInterests.remove(interest);
                                  return state.copyWith(interests: newInterests);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _interestController,
                                decoration: const InputDecoration(
                                  labelText: 'Thêm sở thích mới',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_interestController.text.isNotEmpty) {
                                  _profileStore.update((state) {
                                    final newInterests = List<String>.from(state.interests);
                                    newInterests.add(_interestController.text);
                                    return state.copyWith(interests: newInterests);
                                  });
                                  _interestController.clear();
                                }
                              },
                              child: const Text('Thêm'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              _buildSection(
                title: 'Cài đặt',
                child: StateSelector<UserProfile, Map<String, bool>>(
                  selector: (profile) => profile.settings,
                  builder: (context, settings) {
                    print('UserProfilePage: Settings section rebuilt - items: ${settings.length}');
                    return Column(
                      children: settings.entries.map((entry) {
                        final key = entry.key;
                        final value = entry.value;
                        final title = _getSettingTitle(key);
                        return SwitchListTile(
                          title: Text(title),
                          value: value,
                          onChanged: (newValue) {
                            _profileStore.update((state) {
                              final newSettings = Map<String, bool>.from(state.settings);
                              newSettings[key] = newValue;
                              return state.copyWith(settings: newSettings);
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              _buildSection(
                title: 'Xuất dạng JSON',
                child: StateConsumer<UserProfile>(
                  builder: (context, profile, store) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            profile.toJson().toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            print('UserProfilePage: Updating nested field - city');
                            final profileMap = profile.toJson();
                            final updatedMap = profileMap.updateNestedField(
                              'address.city', 
                              'Hà Nội'
                            );
                            if (updatedMap is Map) {
                              final safeMap = Map<String, dynamic>.from(updatedMap);
                              store.state = UserProfile.fromJson(safeMap);
                            }
                          },
                          child: const Text('Cập nhật thành phố thành Hà Nội'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  String _getSettingTitle(String key) {
    switch (key) {
      case 'enableNotifications':
        return 'Bật thông báo';
      case 'darkMode':
        return 'Chế độ tối';
      case 'autoSync':
        return 'Tự động đồng bộ';
      default:
        return key;
    }
  }
}
