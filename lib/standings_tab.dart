import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

// --------------- Data Model ---------------
class StandingEntry {
  final int originalRank;
  final String displayName;
  final String playerStatus;
  final String finalPicks;
  final double pts;
  final double upsetPts;
  final double accuracy; // 0–100
  final String accuracyLabel;

  const StandingEntry({
    required this.originalRank,
    required this.displayName,
    required this.playerStatus,
    required this.finalPicks,
    required this.pts,
    required this.upsetPts,
    required this.accuracy,
    required this.accuracyLabel,
  });
}

// --------------- Sort State ---------------
enum SortColumn { name, upsetPts, accuracy, totalPts }

// --------------- Widget ---------------
class StandingsTab extends StatefulWidget {
  final ValueNotifier<int> reloadNotifier;
  const StandingsTab({super.key, required this.reloadNotifier});

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  List<StandingEntry>? _entries;
  List<StandingEntry>? _sorted;
  bool _isLoading = false;
  String? _errorMessage;
  String _emptyMessage = 'No standings found.';

  SortColumn _sortCol = SortColumn.totalPts;
  bool _sortAsc = false; // default: highest pts first

  @override
  void initState() {
    super.initState();
    _fetchStandings();
    widget.reloadNotifier.addListener(_fetchStandings);
  }

  @override
  void dispose() {
    widget.reloadNotifier.removeListener(_fetchStandings);
    super.dispose();
  }

  // --------------- Fetch & Parse ---------------
  Future<void> _fetchStandings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emptyMessage = 'No standings found.';
    });

    try {
      final response = await http.get(Uri.parse(
        'https://docs.google.com/spreadsheets/d/1fV19NHTP7gFtLNB36XOF8nmoNBc5bjXqXHxMAfmR3oo/export?format=csv&gid=0',
      ));

      if (response.statusCode == 200) {
        final csvData =
            const CsvToListConverter(eol: "\n").convert(response.body);

        final notOpenYet = csvData.isNotEmpty &&
            csvData.first.any((cell) => cell
                .toString()
                .toLowerCase()
                .contains('not open yet'));
        if (notOpenYet) {
          setState(() {
            _entries = const [];
            _applySort();
            _emptyMessage = 'No standings available yet!';
            _isLoading = false;
          });
          return;
        }

        // Skip row 0 (title) and row 1 (header "Rank, First Last…")
        // Format: [empty, Rank, Name, Pts, %, UpPts, FinalPicks, FF, ...]
        final entries = <StandingEntry>[];
        for (var row in csvData.skip(2)) {
          if (row.length <= 3) continue;
          final rankStr = row[1].toString().trim();
          if (rankStr.isEmpty || rankStr == 'Rank') continue;

          final rank = int.tryParse(rankStr.replaceAll(RegExp(r'\.0$'), '')) ?? 0;
          final rawName = row[2].toString();

          // Parse "First Last (Yr)"
          String displayName = rawName.trim();
          String playerStatus = '';
          final match = RegExp(r'(.*?)\((.*?)\)').firstMatch(rawName.trim());
          if (match != null) {
            displayName = match.group(1)?.trim() ?? rawName.trim();
            final yr = match.group(2)?.trim() ?? '';
            playerStatus =
                yr.toUpperCase() == 'R' ? 'ROOKIE' : '$yr-time Player';
          }

          // Points: "168,50" → 168.50
          final ptsStr =
              row[3].toString().replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
          final pts = double.tryParse(ptsStr) ?? 0.0;

          // Accuracy: "83%" → 83.0
          final accStr = row.length > 4
              ? row[4].toString().replaceAll('%', '').trim()
              : '0';
          final accuracy = double.tryParse(accStr) ?? 0.0;
          final accuracyLabel =
              row.length > 4 ? row[4].toString().trim() : '';

          // Upset pts: "1,5" → 1.5
          final upStr = row.length > 5
              ? row[5]
                    .toString()
                    .replaceAll(',', '.')
                    .replaceAll(RegExp(r'[^0-9.]'), '')
              : '0';
          final upsetPts = double.tryParse(upStr) ?? 0.0;

          final finalPicks =
              row.length > 6 ? row[6].toString().trim() : '';

          entries.add(StandingEntry(
            originalRank: rank,
            displayName: displayName,
            playerStatus: playerStatus,
            finalPicks: finalPicks,
            pts: pts,
            upsetPts: upsetPts,
            accuracy: accuracy,
            accuracyLabel: accuracyLabel,
          ));
        }

        setState(() {
          _entries = entries;
          _applySort();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load standings (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to the internet.';
        _isLoading = false;
      });
    }
  }

  void _applySort() {
    if (_entries == null) return;
    final list = List<StandingEntry>.from(_entries!);
    list.sort((a, b) {
      int cmp;
      switch (_sortCol) {
        case SortColumn.name:
          cmp = a.displayName.compareTo(b.displayName);
          break;
        case SortColumn.upsetPts:
          cmp = a.upsetPts.compareTo(b.upsetPts);
          break;
        case SortColumn.accuracy:
          cmp = a.accuracy.compareTo(b.accuracy);
          break;
        case SortColumn.totalPts:
          cmp = a.pts.compareTo(b.pts);
          break;
      }
      return _sortAsc ? cmp : -cmp;
    });
    _sorted = list;
  }

  void _onHeaderTap(SortColumn col) {
    setState(() {
      if (_sortCol == col) {
        _sortAsc = !_sortAsc;
      } else {
        _sortCol = col;
        _sortAsc = col == SortColumn.name; // name defaults asc, numbers desc
      }
      _applySort();
    });
  }

  // --------------- Build ---------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading && _entries == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _entries == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _fetchStandings, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_sorted == null || _sorted!.isEmpty) {
      return Center(
        child: Text(_emptyMessage,
            style: const TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchStandings,
      child: CustomScrollView(
        slivers: [
          // Sticky header
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              sortCol: _sortCol,
              sortAsc: _sortAsc,
              onTap: _onHeaderTap,
            ),
          ),
          // Data rows
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildRow(_sorted![index], index),
                childCount: _sorted!.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(StandingEntry e, int index) {
    final isEven = index % 2 == 0;
    final bgColor =
        isEven ? Colors.transparent : Colors.grey.withValues(alpha: 0.06);

    final ptsFormatted = e.pts == e.pts.truncateToDouble()
        ? e.pts.toStringAsFixed(2)
        : e.pts.toStringAsFixed(2);
    final upFormatted = e.upsetPts == e.upsetPts.truncateToDouble()
        ? e.upsetPts.toStringAsFixed(1)
        : e.upsetPts.toStringAsFixed(1);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Left 60%: rank circle + name block ---
          Expanded(
            flex: 6,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade700,
                  radius: 15,
                  child: Text(
                    '${e.originalRank}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              e.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (e.playerStatus.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              e.playerStatus,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                      if (e.finalPicks.isNotEmpty)
                        Text(
                          e.finalPicks,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- Upset Pts 15% ---
          Expanded(
            flex: 2,
            child: Text(
              upFormatted,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
          const SizedBox(width: 6),
          // --- Accuracy 15% ---
          Expanded(
            flex: 2,
            child: Text(
              e.accuracyLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Colors.purple),
            ),
          ),
          const SizedBox(width: 6),
          // --- Total Pts 15% ---
          Expanded(
            flex: 2,
            child: Text(
              ptsFormatted,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------- Sticky Header Delegate ---------------
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final SortColumn sortCol;
  final bool sortAsc;
  final void Function(SortColumn) onTap;

  const _HeaderDelegate({
    required this.sortCol,
    required this.sortAsc,
    required this.onTap,
  });

  @override
  double get minExtent => 56; // enough for text and padding
  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.blue.shade800,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left 60% – Name header
          Expanded(
            flex: 6,
            child: _HeaderCell(
              label: 'Player',
              col: SortColumn.name,
              active: sortCol == SortColumn.name,
              asc: sortAsc,
              onTap: onTap,
              align: TextAlign.left,
            ),
          ),
          // Upset Pts 15%
          Expanded(
            flex: 2,
            child: _HeaderCell(
              label: 'Up. Pts',
              col: SortColumn.upsetPts,
              active: sortCol == SortColumn.upsetPts,
              asc: sortAsc,
              onTap: onTap,
              align: TextAlign.right,
            ),
          ),
          const SizedBox(width: 6),
          // Accuracy 15%
          Expanded(
            flex: 2,
            child: _HeaderCell(
              label: 'Accuracy',
              col: SortColumn.accuracy,
              active: sortCol == SortColumn.accuracy,
              asc: sortAsc,
              onTap: onTap,
              align: TextAlign.right,
            ),
          ),
          const SizedBox(width: 6),
          // Total Pts 15%
          Expanded(
            flex: 2,
            child: _HeaderCell(
              label: 'Pts',
              col: SortColumn.totalPts,
              active: sortCol == SortColumn.totalPts,
              asc: sortAsc,
              onTap: onTap,
              align: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.sortCol != sortCol || old.sortAsc != sortAsc;
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final SortColumn col;
  final bool active;
  final bool asc;
  final void Function(SortColumn) onTap;
  final TextAlign align;

  const _HeaderCell({
    required this.label,
    required this.col,
    required this.active,
    required this.asc,
    required this.onTap,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    final icon = active
        ? (asc ? Icons.arrow_upward : Icons.arrow_downward)
        : null;

    return GestureDetector(
      onTap: () => onTap(col),
      child: Row(
        mainAxisAlignment: align == TextAlign.left
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (align == TextAlign.right && icon != null)
            Icon(icon, size: 12, color: Colors.white),
          if (align == TextAlign.right && icon != null)
            const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (align == TextAlign.left && icon != null)
            const SizedBox(width: 2),
          if (align == TextAlign.left && icon != null)
            Icon(icon, size: 12, color: Colors.white),
        ],
      ),
    );
  }
}
