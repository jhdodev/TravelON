// Mocks generated by Mockito 5.4.4 from annotations
// in travel_on_final/test/features/home/presentaion/providers/home_provider_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart'
    as _i5;
import 'package:travel_on_final/features/home/domain/repositories/home_repository.dart'
    as _i2;
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart'
    as _i3;

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

class _FakeHomeRepository_0 extends _i1.SmartFake
    implements _i2.HomeRepository {
  _FakeHomeRepository_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [GetNextTrip].
///
/// See the documentation for Mockito's code generation for more information.
class MockGetNextTrip extends _i1.Mock implements _i3.GetNextTrip {
  MockGetNextTrip() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.HomeRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeHomeRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.HomeRepository);

  @override
  _i4.Future<_i5.NextTripEntity?> call(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #call,
          [userId],
        ),
        returnValue: _i4.Future<_i5.NextTripEntity?>.value(),
      ) as _i4.Future<_i5.NextTripEntity?>);
}
