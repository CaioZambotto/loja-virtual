import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/helpers/validators.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            child: Text(
              'CRIAR CONTA',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
                      textInputAction: TextInputAction.next,
                      controller: emailController,
                      enabled: !userManager.loading,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (email){
                        if(!emailValid(email.toString()))
                          return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      controller: passController,
                      enabled: !userManager.loading,
                      decoration: const InputDecoration(hintText: 'Senha'),
                      autocorrect: false,
                      obscureText: true,
                      validator: (pass){
                        if(pass!.isEmpty || pass!.length < 6)
                          return 'Senha inválida';
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: (){

                        },
                        //padding: EdgeInsets.zero,
                        child: const Text(
                            'Esqueci minha senha'
                        ),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    ElevatedButton(
                      onPressed: userManager.loading ? null : (){
                        if(formKey.currentState!.validate()){
                          userManager.signIn(
                            user: Users(
                              email: emailController.text,
                              password: passController.text
                            ),
                            onFail: (e){
                              ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Falha ao entrar: $e'), duration: Duration(seconds: 3), ), );
                            },
                            onSuccess: (){
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      child: userManager.loading ?
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ) :
                      const Text(
                        'Entrar',
                        style: TextStyle(
                            fontSize: 15
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.teal, // Background color
                        disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
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