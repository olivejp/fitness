import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_user/domain/storage-file.domain.dart';
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:flutter/material.dart';

///
/// Avatar sélectionnable : affiche une image et permet de la remplacer ou de
/// la supprimer.
///
/// Priorité d'affichage :
///   1. [imageUrl] — image déjà stockée à distance ;
///   2. les octets de [storageFile] — image choisie, pas encore envoyée ;
///   3. à défaut, un aplat de la couleur primaire.
///
/// Ce fichier hébergeait auparavant deux autres variantes,
/// `StorageFutureImageWidget` et `StorageStreamImageWidget`, qui ne différaient
/// que par la source de l'image (Future ou Stream). Aucune n'avait d'appelant :
/// elles sont supprimées, avec le `StorageImageFormField` qui ne servait
/// qu'à elles (voir MIGRATION.md, chantier 14).
///
class StorageImageWidget extends StatelessWidget {
  const StorageImageWidget({
    super.key,
    required this.onSaved,
    this.imageUrl,
    this.storageFile,
    this.allowedExtensions = _defaultAllowedExtensions,
    this.onDeleted,
    this.radius = 50,
  });

  static const List<String> _defaultAllowedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  final FormFieldSetter<StorageFile> onSaved;
  final VoidCallback? onDeleted;
  final List<String> allowedExtensions;
  final String? imageUrl;
  final StorageFile? storageFile;
  final double radius;

  /// L'image à peindre, ou `null` s'il n'y en a aucune.
  ImageProvider<Object>? get _image {
    final String? url = imageUrl;
    if (url != null) {
      return NetworkImage(url);
    }
    final Uint8List? bytes = storageFile?.fileBytes;
    if (bytes != null) {
      return MemoryImage(bytes);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    final ImageProvider<Object>? image = _image;

    return Stack(
      children: <Widget>[
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: color,
              backgroundImage: image,
              // L'icône reste par-dessus la photo : c'est elle qui indique que
              // l'avatar est cliquable.
              child: const Icon(
                Icons.add_photo_alternate,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Le bouton était auparavant affiché en permanence, y compris sans
        // photo à supprimer et sans rappel branché — il ne faisait alors rien.
        if (image != null && onDeleted != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: context.l10n.deletePhoto,
              onPressed: onDeleted,
              icon: Icon(Icons.delete, color: color),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null) {
      return;
    }

    final PlatformFile file = result.files.first;
    onSaved(StorageFile()
      ..fileBytes = file.bytes
      ..fileName = file.name);
  }
}
