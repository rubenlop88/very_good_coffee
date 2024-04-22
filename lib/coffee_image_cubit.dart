import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'coffee_image_state.dart';

class CoffeeImageCubit extends HydratedCubit<CoffeeImageState> {
  CoffeeImageCubit() : super(const CoffeeImageInitial()) {
    if (state.currentCoffee.isEmpty ||
        !state.favoriteCoffees.contains(state.currentCoffee)) {
      fetchImage();
    } else {
      emit(CoffeeImageLoaded(
        currentCoffee: state.currentCoffee,
        favoriteCoffees: state.favoriteCoffees,
      ));
    }
  }

  Future<void> fetchImage() async {
    emit(CoffeeImageLoading(
      currentCoffee: state.currentCoffee,
      favoriteCoffees: state.favoriteCoffees,
    ));
    try {
      final uri = Uri.parse('https://coffee.alexflipnote.dev/random.json');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(CoffeeImageLoaded(
          currentCoffee: data['file'],
          favoriteCoffees: state.favoriteCoffees,
        ));
      } else {
        throw Exception('Failed to load coffee image');
      }
    } catch (e) {
      emit(CoffeeImageError(
        currentCoffee: state.currentCoffee,
        favoriteCoffees: state.favoriteCoffees,
      ));
    }
  }

  void toggleFavorite() {
    var coffee = state.currentCoffee;
    if (state.favoriteCoffees.contains(coffee)) {
      _removeFromFavorites(coffee);
    } else {
      _addToFavorites(coffee);
    }
  }

  void _addToFavorites(String coffee) {
    emit(CoffeeImageLoaded(
      currentCoffee: coffee,
      favoriteCoffees: [...state.favoriteCoffees, coffee],
    ));
  }

  void _removeFromFavorites(String coffee) {
    emit(CoffeeImageLoaded(
      currentCoffee: coffee,
      favoriteCoffees: state.favoriteCoffees.where((c) => c != coffee).toList(),
    ));
  }

  void setCurrentCoffee(String coffee) {
    emit(CoffeeImageLoaded(
      currentCoffee: coffee,
      favoriteCoffees: state.favoriteCoffees,
    ));
  }

  @override
  CoffeeImageState? fromJson(Map<String, dynamic> json) {
    return CoffeeImageInitial(
      currentCoffee: json['currentCoffee'] as String,
      favoriteCoffees: (json['favoriteCoffees'] as List).cast<String>(),
    );
  }

  @override
  Map<String, dynamic>? toJson(CoffeeImageState state) {
    return {
      'currentCoffee': state.currentCoffee,
      'favoriteCoffees': state.favoriteCoffees,
    };
  }
}
