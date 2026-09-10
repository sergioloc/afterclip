import 'package:flutter/material.dart';
import '../../../../data/datasource/local/album_local_datasource.dart';
import '../../../../data/datasource/local/clip_local_datasource.dart';
import '../../../../data/repositories/album_repository_impl.dart';
import '../../../../data/repositories/clip_repository_impl.dart';
import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/clip.dart';
import '../../../../domain/usecases/create_album_usecase.dart';
import '../../../../domain/usecases/delete_album_usecase.dart';
import '../../../../domain/usecases/get_all_albums_usecase.dart';
import '../../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../../domain/usecases/rename_album_usecase.dart';
import '../../../../domain/usecases/set_album_archived_usecase.dart';
import '../../../../util/app_colors.dart';
import '../clips/clips_page.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  late final GetAllAlbumsUseCase _getAllAlbumsUseCase;
  late final CreateAlbumUseCase _createAlbumUseCase;
  late final RenameAlbumUseCase _renameAlbumUseCase;
  late final DeleteAlbumUseCase _deleteAlbumUseCase;
  late final GetAllClipsUseCase _getAllClipsUseCase;
  late final SetAlbumArchivedUseCase _setAlbumArchivedUseCase;
  List<Album> _albums = [];
  List<Clip> _clips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final albumRepo = AlbumRepositoryImpl(AlbumLocalDatasource());
    _getAllAlbumsUseCase = GetAllAlbumsUseCase(albumRepo);
    _createAlbumUseCase = CreateAlbumUseCase(albumRepo);
    _renameAlbumUseCase = RenameAlbumUseCase(albumRepo);
    _deleteAlbumUseCase = DeleteAlbumUseCase(albumRepo);
    _setAlbumArchivedUseCase = SetAlbumArchivedUseCase(albumRepo);
    _getAllClipsUseCase = GetAllClipsUseCase(ClipRepositoryImpl(ClipLocalDatasource()));
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final albums = await _getAllAlbumsUseCase.execute();
    final clips = await _getAllClipsUseCase.execute();
    if (mounted) {
      setState(() {
        _albums = albums;
        _clips = clips;
        _loading = false;
      });
    }
  }

  int _clipCountForAlbum(String? albumId) {
    return _clips.where((c) => c.albumId == albumId).length;
  }

  Future<void> _createAlbum() async {
    final name = await _promptForAlbumName();
    if (name == null || name.trim().isEmpty || !mounted) return;

    await _createAlbumUseCase.execute(name.trim());
    setState(() => _loading = true);
    await _loadAlbums();
  }

  Future<void> _renameAlbum(Album album) async {
    final name = await _promptForAlbumName(initial: album.name);
    if (name == null || name.trim().isEmpty || !mounted) return;

    await _renameAlbumUseCase.execute(album.id, name.trim());
    setState(() => _loading = true);
    await _loadAlbums();
  }

  Future<void> _deleteAlbum(Album album) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        title: const Text(
          'Borrar álbum',
          style: TextStyle(color: AppColors.white),
        ),
        content: Text(
          '¿Seguro que quieres borrar "${album.name}"? Los clips no se eliminarán.',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _deleteAlbumUseCase.execute(album.id);
    setState(() => _loading = true);
    await _loadAlbums();
  }

  Future<void> _toggleArchived(Album album) async {
    await _setAlbumArchivedUseCase.execute(album.id, !album.archived);
    setState(() => _loading = true);
    await _loadAlbums();
  }

  Future<String?> _promptForAlbumName({String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        title: Text(
          initial == null ? 'Nuevo álbum' : 'Renombrar álbum',
          style: const TextStyle(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre del álbum',
            hintStyle: TextStyle(color: AppColors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Aceptar', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _openAllClips() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClipsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text('Álbumes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAlbum,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.white))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: _albums.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _AlbumCard(
                    icon: Icons.grid_view,
                    title: 'Todos los clips',
                    subtitle: '${_clips.length}',
                    onTap: _openAllClips,
                  );
                }
                final album = _albums[index - 1];
                return _AlbumCard(
                  icon: album.archived
                      ? Icons.archive_outlined
                      : Icons.photo_library_outlined,
                  title: album.name,
                  subtitle: '${_clipCountForAlbum(album.id)}',
                  titleColor: album.archived ? AppColors.white54 : AppColors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClipsPage(albumId: album.id, title: album.name, archived: album.archived),
                      ),
                    ).then((_) => _loadAlbums());
                  },
                  onLongPress: () => _showAlbumActions(album),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAlbumActions(Album album) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                album.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${_clipCountForAlbum(album.id)} clips',
                style: const TextStyle(color: AppColors.white54),
              ),
            ),
            const Divider(color: AppColors.white24),
            ListTile(
              leading: Icon(
                album.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
                color: AppColors.white,
              ),
              title: Text(
                album.archived ? 'Quitar de archivo' : 'Archivar',
                style: const TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleArchived(album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.white),
              title: const Text(
                'Renombrar',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _renameAlbum(album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteAlbum(album);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.titleColor = AppColors.white,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white24, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}