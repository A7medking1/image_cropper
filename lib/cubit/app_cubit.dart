
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of(context);

  XFile? pickedFile;
  CroppedFile? croppedFile;

  Future<void> uploadImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      pickedFile = pickedImage;
      cropImage();
    }
    //emit(PickedImageFromGalleryState());
  }

  Future<void> cropImage() async {
    if (pickedFile != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
            showCancelConfirmationDialog: true,
            //showActivitySheetOnDone: true,
            // aspectRatioLockEnabled: true,
            rectHeight: 50,
            rectWidth: 50,
          ),
        ],
      );
      if (croppedImage != null) {
        croppedFile = croppedImage;
       // saveImage();
        emit(CroppedImageState());
      }
    }
  }

  Future saveImage() async {
    final res = await ImageGallerySaver.saveImage(
      croppedFile != null ? await croppedFile!.readAsBytes() : await pickedFile!.readAsBytes(),
      quality: 100,
    );
    Get.defaultDialog(title: 'Status',middleText: 'saved image successfully');
    print(res);
  }

  void clear() {
    pickedFile = null;
    croppedFile = null;
    emit(ClearState());
  }
}
