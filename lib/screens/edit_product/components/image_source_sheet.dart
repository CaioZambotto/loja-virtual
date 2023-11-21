import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageSourceSheet extends StatelessWidget {

  ImageSourceSheet({this.onImageSelected});

  final Function(File)? onImageSelected;

  final ImagePicker? picker = ImagePicker();

  Future<void> editImage(String image, BuildContext context) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Imagem',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
          ),
        ]
    );
    final File imageFile = File(croppedFile!.path);
    if(imageFile != null) {
      onImageSelected!(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid)
      return BottomSheet(
        onClosing: (){},
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final PickedFile? file = await picker!.getImage(source: ImageSource.camera);
                editImage(file!.path, context);
              },
              child: const Text('Câmera'),
            ),
            TextButton(
              onPressed: () async {
                final PickedFile? file = await picker!.getImage(source: ImageSource.gallery);
                editImage(file!.path, context);
              },
              child: const Text('Galeria'),
            ),
          ],
        ),
      );
    else
      return CupertinoActionSheet(
        title: const Text('Selecionar foto para o item'),
        message: const Text('Escolha a origem da foto'),
        cancelButton: CupertinoActionSheetAction(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () async {
              final PickedFile? file = await picker!.getImage(source: ImageSource.camera);
              editImage(file!.path, context);
            },
            child: const Text('Câmera'),
          ),
          TextButton(
              onPressed: () async {
                final PickedFile? file = await picker!.getImage(source: ImageSource.camera);
                editImage(file!.path, context);
              },
              child: const Text('Galeria'),
          )
        ],
      );
  }
}
