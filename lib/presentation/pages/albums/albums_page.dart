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
import '../../../../util/app_spacing.dart';
import '../../widgets/album_list_item.dart';
import '../../widgets/album_name_dialog.dart';
import '../../widgets/albums_summary.dart';
import '../../widgets/page_title.dart';
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
        backgroundColor: AppColors.background,
        title: const Text(
          'Delete album',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: Text(
          'Are you sure you want to delete "${album.name}"? The clips will not be deleted.',
          style: const TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
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

  Future<String?> _promptForAlbumName({String? initial}) {
    final isNew = initial == null;
    return AlbumNameDialog.show(
      context,
      initialValue: initial,
      title: isNew ? 'New album' : 'Rename album',
      confirmLabel: isNew ? 'Create' : 'Save',
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const PageTitle('Albums'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAlbum,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.onBackground))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.large),
              itemCount: _albums.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AlbumsSummary(
                    activeAlbums:
                        _albums.where((a) => !a.archived).length,
                    totalClips: _clips.length,
                  );
                }
                if (index == 1) {
                  return AlbumListItem(
                    title: 'All clips',
                    subtitle: _clipCountLabel(_clips.length),
                    onTap: _openAllClips,
                  );
                }
                final album = _albums[index - 2];
                return AlbumListItem(
                  title: album.name,
                  subtitle: _clipCountLabel(_clipCountForAlbum(album.id)),
                  archived: album.archived,
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

  String _clipCountLabel(int count) =>
      '$count ${count == 1 ? 'clip' : 'clips'}';

  void _showAlbumActions(Album album) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                album.name,
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _clipCountLabel(_clipCountForAlbum(album.id)),
                style: const TextStyle(color: AppColors.outline),
              ),
            ),
            const Divider(color: AppColors.surface),
            ListTile(
              leading: Icon(
                album.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
                color: AppColors.onBackground,
              ),
              title: Text(
                album.archived ? 'Unarchive' : 'Archive',
                style: const TextStyle(color: AppColors.onBackground),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleArchived(album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.onBackground),
              title: const Text(
                'Rename',
                style: TextStyle(color: AppColors.onBackground),
              ),
              onTap: () {
                Navigator.pop(context);
                _renameAlbum(album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
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
