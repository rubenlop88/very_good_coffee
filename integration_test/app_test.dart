import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:integration_test/integration_test.dart';
import 'package:very_good_coffee/main.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(
      () => storage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  patrolWidgetTest(
    'tap on the floating action button, verify counter',
    ($) async {
      await $.pumpWidgetAndSettle(const VeryGoodCoffeeApp());
      await $(Icons.favorite).tap();
      expect($(GridView).$(CoffeeTile), findsNothing);

      await $(Icons.home).tap();
      await $('Add to Favorites').tap();
      await $(Icons.favorite).tap();
      expect($(GridView).$(CoffeeTile), findsOne);

      await $(Icons.home).tap();
      await $('Get another coffee').tap();
      await $('Add to Favorites').tap();
      await $(Icons.favorite).tap();
      expect($(GridView).$(CoffeeTile), findsNWidgets(2));
    },
  );
}

