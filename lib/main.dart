import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:very_good_coffee/coffee_image_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(const VeryGoodCoffeeApp());
}

class VeryGoodCoffeeApp extends StatelessWidget {
  const VeryGoodCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoffeeImageCubit>(
      create: (context) => CoffeeImageCubit(),
      child: BlocBuilder<CoffeeImageCubit, CoffeeImageState>(
        builder: (context, state) => FutureBuilder(
          future: getColorScheme(state),
          builder: (context, snapshot) => MaterialApp(
            title: 'Very Good Coffee',
            theme: ThemeData(colorScheme: snapshot.data),
            darkTheme: ThemeData(
              colorScheme: snapshot.data?.copyWith(
                brightness: Brightness.dark,
              ),
            ),
            home: const VeryGoodCoffeeHome(),
          ),
        ),
      ),
    );
  }

  Future<ColorScheme> getColorScheme(CoffeeImageState state) {
    if (state.currentCoffee.isNotEmpty) {
      return ColorScheme.fromImageProvider(
        brightness: PlatformDispatcher.instance.platformBrightness,
        provider: CachedNetworkImageProvider(
          state.currentCoffee,
        ),
      );
    }
    return Future.value(
      ColorScheme.fromSeed(
        brightness: PlatformDispatcher.instance.platformBrightness,
        seedColor: Colors.deepPurple,
      ),
    );
  }
}

class VeryGoodCoffeeHome extends StatefulWidget {
  const VeryGoodCoffeeHome({super.key});

  @override
  State<VeryGoodCoffeeHome> createState() => _VeryGoodCoffeeHomeState();
}

class _VeryGoodCoffeeHomeState extends State<VeryGoodCoffeeHome> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<PageController>.value(
      value: _pageController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Very Good Coffee',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: const [
            CurrentCoffeePage(),
            FavoriteCoffeesPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
          onTap: (index) => _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          ),
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }
}

class CurrentCoffeePage extends StatelessWidget {
  const CurrentCoffeePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const CoffeeImage(),
            ),
          ),
          const SizedBox(height: 32),
          const Column(
            children: [
              ToggleFavoriteButton(),
              SizedBox(height: 16),
              GetCoffeeButton(),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class FavoriteCoffeesPage extends StatelessWidget {
  const FavoriteCoffeesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var state = context.watch<CoffeeImageCubit>().state;
    return GridView(
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      children: [
        for (final coffee in state.favoriteCoffees)
          CoffeeTile(
            coffee: coffee,
            onTap: () => setCurrentCoffee(context, coffee),
          ),
      ],
    );
  }

  void setCurrentCoffee(BuildContext context, String coffee) {
    context.read<CoffeeImageCubit>().setCurrentCoffee(coffee);
    context.read<PageController>().animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
  }
}

class ToggleFavoriteButton extends StatelessWidget {
  const ToggleFavoriteButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var state = context.watch<CoffeeImageCubit>().state;
    var isFavorite = state.favoriteCoffees.contains(state.currentCoffee);
    var isEnabled = state is CoffeeImageLoaded;
    return SizedBox(
      height: 48,
      width: MediaQuery.sizeOf(context).width,
      child: OutlinedButton(
        onPressed: isEnabled ? () => toggleFavorite(context, isFavorite) : null,
        child: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
      ),
    );
  }

  void toggleFavorite(BuildContext context, bool isFavorite) {
    context.read<CoffeeImageCubit>().toggleFavorite();
    if (!isFavorite) {
      context.read<PageController>().animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
    }
  }
}

class GetCoffeeButton extends StatelessWidget {
  const GetCoffeeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var state = context.watch<CoffeeImageCubit>().state;
    var isEnabled = state is CoffeeImageLoaded || state is CoffeeImageError;
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: 48,
      child: FilledButton(
        onPressed: isEnabled ? () => fetchImage(context) : null,
        child: const Text('Get another coffee'),
      ),
    );
  }

  Future<void> fetchImage(BuildContext context) {
    return context.read<CoffeeImageCubit>().fetchImage();
  }
}

class CoffeeImage extends StatelessWidget {
  const CoffeeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var state = context.watch<CoffeeImageCubit>().state;
    return switch (state) {
      CoffeeImageLoaded() => CoffeeTile(coffee: state.currentCoffee),
      CoffeeImageInitial() || CoffeeImageLoading() => const Placeholder(),
      CoffeeImageError() => const ErrorWidget(),
    };
  }
}

class CoffeeTile extends StatelessWidget {
  const CoffeeTile({
    super.key,
    required this.coffee,
    this.onTap,
  });

  final String coffee;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CachedNetworkImage(
        imageUrl: coffee,
        fit: BoxFit.cover,
        width: MediaQuery.sizeOf(context).width,
        placeholder: (context, url) => const Placeholder(),
        errorWidget: (context, url, error) => const ErrorWidget(),
      ),
    );
  }
}

class Placeholder extends StatelessWidget {
  const Placeholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: baseColor.withAlpha(140),
      child: Container(
        color: Colors.grey,
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.error);
  }
}
