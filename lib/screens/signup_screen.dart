import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Controle de Visibilidade de Senha
  bool _isObscurePass = true;
  bool _isObscureConfirmPass = true;

  // Variáveis para Dropdowns
  String? _selectedGenero;
  final List<String> _generos = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não dizer',
  ];

  // Variáveis do IBGE
  List<dynamic> _estados = [];
  List<dynamic> _cidades = [];
  String? _selectedEstadoSigla; // Enviado para a API
  int? _selectedEstadoId; // Usado para buscar as cidades
  String? _selectedCidadeNome; // Enviado para a API

  String selectedRole = 'Atleta';

  var dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _fetchEstados();
  }

  // Integração com API do IBGE 
  Future<void> _fetchEstados() async {
    final url = Uri.parse(
      'https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _estados = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar estados: $e");
    }
  }

  Future<void> _fetchCidades(int estadoId) async {
    final url = Uri.parse(
      'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$estadoId/municipios?orderBy=nome',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _cidades = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar cidades: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.7),
            radius: 1.5,
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.12), 
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF06B6D4)],
                  ).createShader(bounds),
                  child: const Text(
                    'Criar uma Conta',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Text(
                  'Comece sua jornada no FitLab',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildCompactField(
                        controller: _nameController,
                        label: 'NOME COMPLETO',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildCompactField(
                        controller: _emailController,
                        label: 'EMAIL',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildDropdownField(
                              label: 'ESTADO (UF)',
                              icon: null,
                              value: _selectedEstadoSigla,
                              items: _estados.map((estado) {
                                return DropdownMenuItem<String>(
                                  value: estado['sigla'],
                                  child: Text(
                                    estado['sigla'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  onTap: () => _selectedEstadoId = estado['id'],
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedEstadoSigla = val as String?;
                                  _selectedCidadeNome = null;
                                  _cidades = [];
                                });
                                if (_selectedEstadoId != null) {
                                  _fetchCidades(_selectedEstadoId!);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(flex: 7, child: _buildSearchableCityField()),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildCompactField(
                              controller: _birthDateController,
                              label: 'NASCIMENTO',
                              icon: Icons.calendar_today,
                              formatters: [dateMaskFormatter],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'GÊNERO',
                              icon: Icons.people_outline,
                              value: _selectedGenero,
                              items: _generos.map((gen) {
                                return DropdownMenuItem<String>(
                                  value: gen,
                                  child: Text(
                                    gen,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow
                                        .ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedGenero = val as String?;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildCompactField(
                        controller: _passwordController,
                        label: 'SENHA',
                        icon: Icons.lock_outline,
                        isPass: _isObscurePass,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscurePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscurePass = !_isObscurePass;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCompactField(
                        controller: _confirmPasswordController,
                        label: 'CONFIRMAR SENHA',
                        icon: Icons.shield_outlined,
                        isPass: _isObscureConfirmPass,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureConfirmPass
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirmPass = !_isObscureConfirmPass;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              "TIPO DE CONTA",
                              style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          _buildSlimRoleSelector(),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSubmitButton(),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Já faz parte do time?",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "ENTRAR",
                        style: TextStyle(
                          color: Color(0xFF06B6D4),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    IconData? icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(Object?)? onChanged,
  }) {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white38,
          size: 20,
        ),
        isExpanded: true,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5, 
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white38, size: 18)
              : const Padding(padding: EdgeInsets.only(left: 8.0)),
          prefixIconConstraints: icon != null
              ? null
              : const BoxConstraints(minWidth: 12, minHeight: 0),
          contentPadding: const EdgeInsets.only(top: 12, bottom: 8, right: 4),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF06B6D4)),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPass = false,
    List<TextInputFormatter>? formatters,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: isPass,
        inputFormatters: formatters,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5, 
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(icon, color: Colors.white38, size: 18),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF06B6D4)),
          ),
        ),
      ),
    );
  }

  Widget _buildSlimRoleSelector() {
    return Container(
      height: 50, 
      padding: const EdgeInsets.all(
        4,
      ), 
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _roleBtn("Atleta", Icons.directions_run),
          _roleBtn("Treinador", Icons.biotech),
        ],
      ),
    );
  }

  // Cidade pesquisável
  Widget _buildSearchableCityField() {
    return SizedBox(
      height: 50,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return _cidades.map((c) => c['nome'] as String);
          }
          return _cidades
              .map((c) => c['nome'] as String)
              .where(
                (cidade) => cidade.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
        },
        onSelected: (String selection) {
          setState(() => _selectedCidadeNome = selection);
          FocusManager.instance.primaryFocus?.unfocus(); // Esconde o teclado
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'CIDADE',
              labelStyle: const TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(
                Icons.location_city,
                color: Colors.white38,
                size: 18,
              ),
              contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF06B6D4)),
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: const Color(0xFF2C2C2C), 
              elevation: 8.0,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 220,
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _roleBtn(String role, IconData icon) {
    bool selected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF06B6D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16, 
                color: selected ? Colors.white : Colors.white24,
              ),
              const SizedBox(width: 8),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white24,
                  fontSize: 12, // Fonte maior
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // !!!!!!!!! Lógica de cadastro será implementada aqui !!!!!!!!!!!!
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'CRIAR MINHA CONTA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
