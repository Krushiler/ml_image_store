import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store_app/interactor/auth_interactor.dart';
import 'package:ml_image_store_app/presentation/util/subscription_bloc.dart';

part 'app_navigation_cubit.freezed.dart';

class AppNavigationCubit extends Cubit<AppNavigationState> with SubscriptionBloc {
  final AuthInteractor _authInteractor;

  AppNavigationCubit(this._authInteractor) : super(const AppNavigationState(isSignedIn: false)) {
    subscribe(_authInteractor.watchAuth(), (event) {
      _updateAuthState(event);
    });
  }

  void _updateAuthState(String? auth) {
    if (auth == null) {
      emit(const AppNavigationState(isSignedIn: false));
    } else {
      emit(const AppNavigationState(isSignedIn: true));
    }
  }
}

@freezed
class AppNavigationState with _$AppNavigationState {
  const factory AppNavigationState({required bool isSignedIn}) = _AppNavigationState;
}
