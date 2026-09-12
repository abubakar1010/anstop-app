import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';


class MediaGridScreen extends StatelessWidget {
  const MediaGridScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample media items (you would replace these with actual image URLs)
    final List<String> mediaItems = [
      'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Photo+1',
      'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Photo+2',
      'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Photo+3',
      'https://via.placeholder.com/400x300/E91E63/FFFFFF?text=Photo+4',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: MessagingColors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.tr.mediaTitle,
          style: TextStyle(
            color: MessagingColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: mediaItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _showFullImage(context, mediaItems[index]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: MessagingColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    mediaItems[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: MessagingColors.backgroundColor,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: MessagingColors.secondaryText,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: MessagingColors.backgroundColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: MessagingColors.primaryGreen,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageScreen(imageUrl: imageUrl),
      ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 48,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
