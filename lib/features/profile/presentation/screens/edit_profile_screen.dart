import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/unsaved_changes_dialog.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  static const String route = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // User profile fields
  final _userNameController = TextEditingController();
  final _userPhoneController = TextEditingController();
  bool _hasLoadedData = false;

  // Track initial state to detect changes
  String _initialUserName = '';
  String _initialUserPhone = '';
  bool _shouldPopAfterSave = false;

  @override
  void initState() {
    super.initState();
    // Get current user profile data
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userPhoneController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    if (!_hasLoadedData) return false;

    // Check user profile changes
    if (_userNameController.text.trim() != _initialUserName) return true;
    if (_userPhoneController.text.trim() != _initialUserPhone) return true;

    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) {
      return true; // Allow pop if no changes
    }

    // Show confirmation dialog
    final result = await UnsavedChangesDialog.show(
      context,
      onSave: () {
        _shouldPopAfterSave = true;
        _updateProfile();
      },
    );

    return result ?? false; // Discard if result is null (user clicked outside)
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges()) {
          Navigator.of(context).pop();
          return;
        }

        // Show confirmation dialog
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.editProfile)),
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.requestState == RequestState.error) {
              ErrorSnackBar.show(context, state.message);
            } else if (state.requestState == RequestState.loaded &&
                state.message.isNotEmpty &&
                _hasLoadedData) {
              // Only show success and navigate if data was already loaded (i.e., this is an update, not initial load)
              ErrorSnackBar.showSuccess(
                context,
                'Profile updated successfully',
              );
              // Update initial state after successful save
              _initialUserName = _userNameController.text.trim();
              _initialUserPhone = _userPhoneController.text.trim();
              // Pop if user requested to save and go back
              if (_shouldPopAfterSave && context.mounted) {
                _shouldPopAfterSave = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                });
              }
            }

            // Populate user profile fields
            if (state.profile != null && !_hasLoadedData) {
              _userNameController.text = state.profile!.name;
              _userPhoneController.text = state.profile!.phone;
              // Store initial state
              _initialUserName = state.profile!.name;
              _initialUserPhone = state.profile!.phone;
              _hasLoadedData = true;
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final isLoading =
                  profileState.requestState == RequestState.loading;

              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: MaterialTheme.getGradientBackground(context),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User Profile Section
                              Text(
                                AppLocalizations.of(context)!.profile,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2.h),

                              // User Name Field
                              TextFormField(
                                controller: _userNameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.name,
                                  prefixIcon: const Icon(Icons.person),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 2.h),

                              // User Phone Field
                              TextFormField(
                                controller: _userPhoneController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.phone,
                                  prefixIcon: const Icon(Icons.phone),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    if (value.trim().length < 10) {
                                      return 'Phone number must be at least 10 digits';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 4.h),

                              // Update Button
                              SizedBox(
                                height: MaterialTheme.getSpacing(
                                  'buttonHeight',
                                ).h,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF8A32),
                                    foregroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    minimumSize: Size(
                                      double.infinity,
                                      MaterialTheme.getSpacing(
                                        'buttonHeight',
                                      ).h,
                                    ),
                                    padding: EdgeInsets.zero,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          MaterialTheme.getBorderRadiusButton(),
                                    ),
                                  ),
                                  child: isLoading
                                      ? MaterialTheme.getCircularProgressIndicator(
                                          context,
                                        )
                                      : Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.updateProfile,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Full-page loading overlay
                  if (isLoading)
                    MaterialTheme.getFullPageLoadingOverlay(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // Update user profile
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          name: _userNameController.text.trim(),
          phone: _userPhoneController.text.trim(),
        ),
      );
    }
  }
}
