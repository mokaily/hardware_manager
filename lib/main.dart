import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/theme.dart';
import 'data/services/storage_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/haptics_service.dart';
import 'data/services/brightness_service.dart';
import 'data/repositories/profile_repository.dart';
import 'logic/profile/profile_bloc.dart';
import 'logic/profile/profile_event.dart';
import 'logic/hardware/hardware_bloc.dart';
import 'logic/hardware/hardware_event.dart';
import 'presentation/screens/main_screen.dart';
import 'logic/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = StorageService();
  await storageService.initialize();

  final audioService = AudioService();
  await audioService.initialize();

  final hapticsService = HapticsService();
  await hapticsService.initialize();

  final brightnessService = BrightnessService();
  await brightnessService.initialize();

  // Create repository
  final profileRepository = ProfileRepository(storageService);

  runApp(MyApp(
    profileRepository: profileRepository,
    audioService: audioService,
    hapticsService: hapticsService,
    brightnessService: brightnessService,
  ));
}

class MyApp extends StatelessWidget {
  final ProfileRepository profileRepository;
  final AudioService audioService;
  final HapticsService hapticsService;
  final BrightnessService brightnessService;

  const MyApp({
    super.key,
    required this.profileRepository,
    required this.audioService,
    required this.hapticsService,
    required this.brightnessService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileBloc(profileRepository)
            ..add(const LoadProfiles()),
        ),
        BlocProvider(
          create: (context) => HardwareBloc(
            audioService: audioService,
            hapticsService: hapticsService,
            brightnessService: brightnessService,
          )..add(const InitializeHardware()),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Audio Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
