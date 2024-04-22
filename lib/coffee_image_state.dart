part of 'coffee_image_cubit.dart';

@immutable
sealed class CoffeeImageState {
  final String currentCoffee;
  final List<String> favoriteCoffees;

  const CoffeeImageState({
    this.currentCoffee = '',
    this.favoriteCoffees = const [],
  });
}

class CoffeeImageInitial extends CoffeeImageState {
  const CoffeeImageInitial({
    super.currentCoffee,
    super.favoriteCoffees,
  });
}

class CoffeeImageLoading extends CoffeeImageState {
  const CoffeeImageLoading({
    super.currentCoffee,
    super.favoriteCoffees,
  });
}

class CoffeeImageLoaded extends CoffeeImageState {
  const CoffeeImageLoaded({
    super.currentCoffee,
    super.favoriteCoffees,
  });
}

class CoffeeImageError extends CoffeeImageState {
  const CoffeeImageError({
    super.currentCoffee,
    super.favoriteCoffees,
  });
}
