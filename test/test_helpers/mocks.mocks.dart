// Mocks generated by Mockito 5.4.4 from annotations
// in travel_on_final/test/test_helpers/mocks.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:io' as _i6;
import 'dart:ui' as _i7;

import 'package:flutter/material.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:travel_on_final/features/auth/data/models/user_model.dart'
    as _i5;
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart'
    as _i2;
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart'
    as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [AuthProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthProvider extends _i1.Mock implements _i2.AuthProvider {
  MockAuthProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isEmailVerified => (super.noSuchMethod(
        Invocation.getter(#isEmailVerified),
        returnValue: false,
      ) as bool);

  @override
  set isEmailVerified(bool? _isEmailVerified) => super.noSuchMethod(
        Invocation.setter(
          #isEmailVerified,
          _isEmailVerified,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isAuthenticated => (super.noSuchMethod(
        Invocation.getter(#isAuthenticated),
        returnValue: false,
      ) as bool);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i3.Future<void> login(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #login,
          [
            email,
            password,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> signup(
    String? email,
    String? password,
    String? name,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signup,
          [
            email,
            password,
            name,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> checkEmailVerified() => (super.noSuchMethod(
        Invocation.method(
          #checkEmailVerified,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> logout(_i4.BuildContext? context) => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [context],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<_i5.UserModel?> getUserById(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #getUserById,
          [userId],
        ),
        returnValue: _i3.Future<_i5.UserModel?>.value(),
      ) as _i3.Future<_i5.UserModel?>);

  @override
  _i3.Future<void> certifyAsGuide(_i6.File? certificateImage) =>
      (super.noSuchMethod(
        Invocation.method(
          #certifyAsGuide,
          [certificateImage],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<bool> checkPassword(String? password) => (super.noSuchMethod(
        Invocation.method(
          #checkPassword,
          [password],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<void> updateUserProfile({
    required String? name,
    String? gender,
    DateTime? birthDate,
    String? profileImageUrl,
    String? backgroundImageUrl,
    String? introduction,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUserProfile,
          [],
          {
            #name: name,
            #gender: gender,
            #birthDate: birthDate,
            #profileImageUrl: profileImageUrl,
            #backgroundImageUrl: backgroundImageUrl,
            #introduction: introduction,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> resetPassword(String? email) => (super.noSuchMethod(
        Invocation.method(
          #resetPassword,
          [email],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> toggleLikePackage(String? packageId) => (super.noSuchMethod(
        Invocation.method(
          #toggleLikePackage,
          [packageId],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<List<_i5.UserModel>> searchUsers(String? query) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchUsers,
          [query],
        ),
        returnValue: _i3.Future<List<_i5.UserModel>>.value(<_i5.UserModel>[]),
      ) as _i3.Future<List<_i5.UserModel>>);

  @override
  _i3.Future<void> signInWithGoogle() => (super.noSuchMethod(
        Invocation.method(
          #signInWithGoogle,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> signInWithGithub(_i4.BuildContext? context) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithGithub,
          [context],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> signInWithKakao(_i4.BuildContext? context) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithKakao,
          [context],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [HomeProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockHomeProvider extends _i1.Mock implements _i8.HomeProvider {
  MockHomeProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isLoading => (super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
      ) as bool);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i3.Future<void> loadNextTrip(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #loadNextTrip,
          [userId],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
