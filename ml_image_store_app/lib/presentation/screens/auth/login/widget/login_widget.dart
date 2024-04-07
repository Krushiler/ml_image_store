import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';
import 'package:ml_image_store_app/presentation/util/snackbar_util.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Scaffold(
          body: BlocListener<LoginBloc, LoginState>(
            listenWhen: (_, curr) => curr.error != null,
            listener: (context, state) {
              context.showErrorSnackBar(state.error ?? '');
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimens.md).add(Dimens.system(context)),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.md),
                    child: SizedBox(
                      width: 600,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: loginController,
                            enabled: !state.loading,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(labelText: 'Login'),
                            onChanged: (value) => context.read<LoginBloc>().add(LoginEvent.loginChanged(value)),
                          ),
                          Gap.md,
                          TextFormField(
                            controller: passwordController,
                            enabled: !state.loading,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: const InputDecoration(labelText: 'Password'),
                            onChanged: (value) => context.read<LoginBloc>().add(LoginEvent.passwordChanged(value)),
                          ),
                          Gap.md,
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.loading
                                  ? null
                                  : () => context.read<LoginBloc>().add(const LoginEvent.loginRequested()),
                              child: const Text('Login'),
                            ),
                          ),
                          Gap.md,
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: state.loading
                                  ? null
                                  : () => context.read<LoginBloc>().add(const LoginEvent.registerRequested()),
                              child: const Text('Register'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
