import 'package:flutter/material.dart';
import 'package:loja_virtual/helpers/validators.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  late Users usuario;
  String _confirmSenha = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: Consumer<UserManager>(
              builder: (_, userManager, __){
                return ListView(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: <Widget>[
                    TextFormField(
                      enabled: !userManager.loading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(hintText: 'Nome Completo'),
                      validator: (name){
                        if(name!.isEmpty)
                          return 'Campo obrigatório';
                        else if(name.trim().split(' ').length <= 1)
                          return 'Preencha seu Nome completo';
                        return null;
                      },
                      onSaved: (name) {
                        _nameController.text = name!;
                      },
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      enabled: !userManager.loading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (email){
                        if(email!.isEmpty)
                          return 'Campo obrigatório';
                        else if(!emailValid(email))
                          return 'E-mail inválido';
                        return null;
                      },
                      onSaved: (email) {
                        _emailController.text = email!;
                      },
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      enabled: !userManager.loading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(hintText: 'Senha'),
                      obscureText: true,
                      validator: (pass){
                        if(pass!.isEmpty)
                          return 'Campo obrigatório';
                        else if(pass!.length < 6)
                          return 'Senha muito curta';
                        return null;
                      },
                      onSaved: (pass) {
                        _passwordController.text = pass!;
                      },
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      enabled: !userManager.loading,
                      decoration: const InputDecoration(hintText: 'Repita a Senha'),
                      obscureText: true,
                      validator: (pass){
                        if(pass!.isEmpty)
                          return 'Campo obrigatório';
                        else if(pass!.length < 6)
                          return 'Senha muito curta';
                        return null;
                      },
                      onSaved: (pass) {
                        _confirmSenha = pass!;
                      },
                    ),
                    const SizedBox(height: 16,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.teal, // Background color
                        disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                      ),
                      onPressed: userManager.loading ? null : (){
                        if(formKey.currentState!.validate()){
                          formKey.currentState!.save();

                          usuario = Users(
                              email: _emailController.text,
                              password: _passwordController.text,
                              name: _nameController.text
                          );

                          if (usuario.password != _confirmSenha) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              content: const Text('As senhas não conferem'),
                              duration: const Duration(seconds: 3),
                            )
                            );
                            return;
                          }
                          userManager.signUp(
                              user: usuario,
                              onFail: (e){
                                ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Falha ao cadastrar: $e'), duration: Duration(seconds: 3), ), );
                              },
                              onSuccess: (){
                                Navigator.of(context).pop();
                              }
                          );
                        }
                      },
                      child: userManager.loading ?
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                      : const Text(
                        'Criar Conta',
                        style: TextStyle(
                            fontSize: 15
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}