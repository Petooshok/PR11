import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Константы для цветов и размеров
const Color primaryColor = Color(0xFFC84B31);
const Color secondaryColor = Color(0xFFECDBBA);
const Color textColor = Color(0xFF56423D);
const Color backgroundColor = Color(0xFF191919);
const double defaultPadding = 16.0;
const double defaultRadius = 10.0;
const double defaultTextSize = 14.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  String? _gender = 'М';

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Container(
                padding: const EdgeInsets.all(defaultPadding),
                width: screenWidth < 600 ? screenWidth * 0.9 : 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MANgo100',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 24.0 : 32.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAvatarAndInfo(),
                    const SizedBox(height: 24),
                    _buildGenderAndCityAndBirthDateField(),
                    const SizedBox(height: 24),
                    _buildInputField('Email', _emailController, hintText: 'example@example.com'),
                    const SizedBox(height: 24),
                    _buildInputField('Password', _passwordController, obscureText: true, hintText: 'Минимум 8 символов'),
                    const SizedBox(height: 24),
                    _buildInputField('Confirm Password', _confirmPasswordController, obscureText: true, hintText: 'Повторите пароль'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAvatarAndInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Добавьте ссылку на изображение'),
                  content: TextField(
                    controller: _avatarUrlController,
                    decoration: const InputDecoration(hintText: 'Введите ссылку на изображение'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {}); // Обновляем виджет после ввода ссылки
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15.0),
              color: primaryColor,
            ),
            child: _avatarUrlController.text.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      _avatarUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: secondaryColor,
                            size: 32.0,
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.add,
                      color: secondaryColor,
                      size: 32.0,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInputField(
            'Full Name',
            _fullNameController,
            hintText: 'Иванов Иван Иванович',
          ),
        ),
      ],
    );
  }

  Widget _buildGenderAndCityAndBirthDateField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGenderSelection(),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBirthDateField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCitySelection(),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscureText = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: textColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: textColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(
            color: textColor,
            fontSize: defaultTextSize,
            fontFamily: 'Tektur',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, введите $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Пол',
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Radio<String>(
              value: 'М',
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              activeColor: primaryColor,
            ),
            const Text('М', style: TextStyle(color: textColor)),
            Radio<String>(
              value: 'Ж',
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              activeColor: primaryColor,
            ),
            const Text('Ж', style: TextStyle(color: textColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildCitySelection() {
    const List<String> cities = [
      'Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Нижний Новгород', 'Казань', 'Челябинск', 'Омск', 'Самара', 'Ростов-на-Дону'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Город',
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 5),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return cities.where((String city) {
              return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            setState(() {
              _cityController.text = selection;
            });
          },
          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: secondaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: const BorderSide(color: textColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: const BorderSide(color: textColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: const BorderSide(color: primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(
                color: textColor,
                fontSize: defaultTextSize,
                fontFamily: 'Tektur',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите город';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дата рождения',
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _birthDateController,
          decoration: InputDecoration(
            hintText: 'ДД.ММ.ГГГГ',
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: textColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: textColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(
            color: textColor,
            fontSize: defaultTextSize,
            fontFamily: 'Tektur',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, введите дату рождения';
            }
            return null;
          },
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _birthDateController.text = "${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}";
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Избранное',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Корзина',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
      ],
      currentIndex: 3, // Устанавливаем текущий индекс на "Профиль"
      selectedItemColor: const Color.fromRGBO(200, 75, 49, 1),
      unselectedItemColor: const Color(0xFFECDBBA),
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/manga_selected');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/cart');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}