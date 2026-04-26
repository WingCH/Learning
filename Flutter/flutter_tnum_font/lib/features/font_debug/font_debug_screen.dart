import 'package:flutter/material.dart';
import 'package:flutter_tnum_font/core/config/render_profiles.dart';
import 'package:flutter_tnum_font/core/config/sample_strings.dart';
import 'package:flutter_tnum_font/core/models/device_debug_info.dart';
import 'package:flutter_tnum_font/core/models/font_debug_snapshot.dart';
import 'package:flutter_tnum_font/core/models/font_evidence_summary.dart';
import 'package:flutter_tnum_font/core/services/font_debug_service.dart';

class FontDebugScreen extends StatefulWidget {
  const FontDebugScreen({required this.service, super.key});

  final FontDebugService service;

  @override
  State<FontDebugScreen> createState() => _FontDebugScreenState();
}

class _FontDebugScreenState extends State<FontDebugScreen> {
  late final List<RenderProfile> _renderProfiles;
  late final List<SampleStringCase> _sampleCases;
  late final ScrollController _scrollController;
  late RenderProfile _selectedProfile;
  FontDebugSnapshot? _snapshot;
  Object? _loadError;
  bool _isLoading = true;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _renderProfiles = RenderProfile.defaults();
    _sampleCases = kDefaultSampleCases;
    _scrollController = ScrollController();
    _selectedProfile = _renderProfiles.first;
    _loadSnapshotIntoState(profile: _selectedProfile, updateState: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<FontDebugSnapshot> _loadSnapshot({required RenderProfile profile}) {
    return widget.service.loadSnapshot(
      profile: profile,
      sampleCases: _sampleCases,
    );
  }

  void _loadSnapshotIntoState({
    required RenderProfile profile,
    bool updateState = true,
  }) {
    final requestId = _loadRequestId + 1;
    _loadRequestId = requestId;

    void markLoading() {
      _isLoading = true;
      _loadError = null;
    }

    if (updateState) {
      setState(markLoading);
    } else {
      markLoading();
    }

    _loadSnapshot(profile: profile).then(
      (snapshot) {
        if (!mounted || requestId != _loadRequestId) {
          return;
        }

        setState(() {
          _snapshot = snapshot;
          _isLoading = false;
          _loadError = null;
        });
      },
      onError: (Object error) {
        if (!mounted || requestId != _loadRequestId) {
          return;
        }

        setState(() {
          _loadError = error;
          _isLoading = false;
        });
      },
    );
  }

  void _onProfileChanged(String? profileId) {
    if (profileId == null) {
      return;
    }

    final nextProfile = _renderProfiles.firstWhere(
      (profile) => profile.id == profileId,
    );

    if (nextProfile.id == _selectedProfile.id) {
      return;
    }

    setState(() {
      _selectedProfile = nextProfile;
    });
    _loadSnapshotIntoState(profile: nextProfile);
  }

  void _onRefreshPressed() {
    _loadSnapshotIntoState(profile: _selectedProfile);
  }

  @override
  Widget build(BuildContext context) {
    final data = _snapshot;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Android tnum 偵測工具'),
        actions: [
          IconButton(
            onPressed: _onRefreshPressed,
            tooltip: '重新整理裝置偵測結果',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: data == null
          ? _InitialLoadState(
              error: _loadError,
              onRetryPressed: _onRefreshPressed,
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  key: const ValueKey<String>('font-debug-scroll-view'),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _HeroCard(
                        profile: _selectedProfile,
                        evidenceSummary: data.evidenceSummary,
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'tnum 對照',
                        child: _TnumComparison(
                          profile: _selectedProfile,
                          sampleCases: data.sampleCases,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Render 設定',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              key: ValueKey<String>(_selectedProfile.id),
                              initialValue: _selectedProfile.id,
                              onChanged: _onProfileChanged,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '指定 family 路徑',
                              ),
                              items: _renderProfiles
                                  .map(
                                    (profile) => DropdownMenuItem<String>(
                                      value: profile.id,
                                      child: Text(profile.label),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedProfile.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: '裝置資訊',
                        child: _DeviceInfoGrid(deviceInfo: data.deviceInfo),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: '字體證據',
                        child: _FontEvidenceList(summary: data.evidenceSummary),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
    );
  }
}

class _InitialLoadState extends StatelessWidget {
  const _InitialLoadState({required this.error, required this.onRetryPressed});

  final Object? error;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error != null) {
      return _ErrorState(
        onRetryPressed: onRetryPressed,
        message: '無法載入 Android 字體偵測資料。\n$error',
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile, required this.evidenceSummary});

  final RenderProfile profile;
  final FontEvidenceSummary evidenceSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B7285), Color(0xFF1D3557)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '偵測狀態',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            evidenceSummary.headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EvidenceStatePill(state: evidenceSummary.state),
              _DarkPill(label: '設定：${profile.label}'),
              _DarkPill(
                label: '指定 family：${profile.requestedFamily ?? '系統預設'}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoGrid extends StatelessWidget {
  const _DeviceInfoGrid({required this.deviceInfo});

  final DeviceDebugInfo deviceInfo;

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, String>>[
      MapEntry<String, String>('製造商', deviceInfo.manufacturer),
      MapEntry<String, String>('型號', deviceInfo.model),
      MapEntry<String, String>('Android 版本', deviceInfo.androidRelease),
      MapEntry<String, String>('SDK 版本', '${deviceInfo.sdkInt}'),
      MapEntry<String, String>('目前 family', deviceInfo.configuredFamilyLabel),
      MapEntry<String, String>('Render 路徑', deviceInfo.renderPathLabel),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: entries
          .map(
            (entry) => SizedBox(
              width: 260,
              child: _InfoTile(label: entry.key, value: entry.value),
            ),
          )
          .toList(),
    );
  }
}

class _FontEvidenceList extends StatelessWidget {
  const _FontEvidenceList({required this.summary});

  final FontEvidenceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EvidenceStateBanner(summary: summary),
        const SizedBox(height: 16),
        for (final item in summary.items) ...[
          _EvidenceItemTile(item: item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TnumComparison extends StatelessWidget {
  const _TnumComparison({required this.profile, required this.sampleCases});

  final RenderProfile profile;
  final List<SampleStringCase> sampleCases;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MixedFontExample(profile: profile, sampleCases: sampleCases),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            Expanded(
              flex: 3,
              child: Text(
                'tnum 關閉',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'tnum 開啟',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sampleCases.map(
          (sample) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9E1E5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      sample.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _MeasuredSampleCell(
                      profile: profile,
                      value: sample.value,
                      enableTnum: false,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _MeasuredSampleCell(
                      profile: profile,
                      value: sample.value,
                      enableTnum: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MeasuredSampleCell extends StatelessWidget {
  const _MeasuredSampleCell({
    required this.profile,
    required this.value,
    required this.enableTnum,
  });

  final RenderProfile profile;
  final String value;
  final bool enableTnum;

  @override
  Widget build(BuildContext context) {
    final style = _sampleTextStyle(
      context: context,
      profile: profile,
      enableTnum: enableTnum,
    );
    final width = _measureTextWidth(
      context: context,
      value: value,
      style: style,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
          style: style,
        ),
        const SizedBox(height: 4),
        Text(
          '闊度：${width.toStringAsFixed(1)} px',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF5C6770),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MixedFontExample extends StatelessWidget {
  const _MixedFontExample({required this.profile, required this.sampleCases});

  final RenderProfile profile;
  final List<SampleStringCase> sampleCases;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFD9E1E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '混合字體例子',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final sample in sampleCases) ...[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: sample.datePart,
                    style: _sampleTextStyle(
                      context: context,
                      profile: profile,
                      enableTnum: false,
                    ),
                  ),
                  TextSpan(
                    text: ' ${sample.statusPart}',
                    style: _sampleTextStyle(
                      context: context,
                      profile: profile,
                      enableTnum: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _InlineLegend(label: '04-22：預設'),
              _InlineLegend(label: '狀態：tnum'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineLegend extends StatelessWidget {
  const _InlineLegend({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF1864AB),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF8F5EF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF6B705C),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EvidenceStateBanner extends StatelessWidget {
  const _EvidenceStateBanner({required this.summary});

  final FontEvidenceSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = switch (summary.state) {
      FontEvidenceState.confirmed => const Color(0xFFD3F9D8),
      FontEvidenceState.candidate => const Color(0xFFFFF3BF),
      FontEvidenceState.inconclusive => const Color(0xFFFFE3E3),
    };

    final border = switch (summary.state) {
      FontEvidenceState.confirmed => const Color(0xFF2B8A3E),
      FontEvidenceState.candidate => const Color(0xFFF08C00),
      FontEvidenceState.inconclusive => const Color(0xFFC92A2A),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Text(
        summary.headline,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: border,
        ),
      ),
    );
  }
}

class _EvidenceItemTile extends StatelessWidget {
  const _EvidenceItemTile({required this.item});

  final FontEvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.tone) {
      FontEvidenceTone.evidence => const Color(0xFFEDF6F9),
      FontEvidenceTone.limitation => const Color(0xFFFFF1F2),
    };

    final border = switch (item.tone) {
      FontEvidenceTone.evidence => const Color(0xFFBDE0E8),
      FontEvidenceTone.limitation => const Color(0xFFFFCCD5),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(item.detail),
        ],
      ),
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EvidenceStatePill extends StatelessWidget {
  const _EvidenceStatePill({required this.state});

  final FontEvidenceState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      FontEvidenceState.confirmed => 'confirmed / 已確認',
      FontEvidenceState.candidate => 'candidate / 候選',
      FontEvidenceState.inconclusive => 'inconclusive / 無法確認',
    };

    final background = switch (state) {
      FontEvidenceState.confirmed => const Color(0xFFD3F9D8),
      FontEvidenceState.candidate => const Color(0xFFFFF3BF),
      FontEvidenceState.inconclusive => const Color(0xFFFFE3E3),
    };

    final foreground = switch (state) {
      FontEvidenceState.confirmed => const Color(0xFF2B8A3E),
      FontEvidenceState.candidate => const Color(0xFFDD6B20),
      FontEvidenceState.inconclusive => const Color(0xFFC92A2A),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetryPressed, required this.message});

  final VoidCallback onRetryPressed;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetryPressed, child: const Text('重試')),
          ],
        ),
      ),
    );
  }
}

TextStyle _sampleTextStyle({
  required BuildContext context,
  required RenderProfile profile,
  required bool enableTnum,
}) {
  return Theme.of(context).textTheme.headlineSmall!.copyWith(
    fontFamily: profile.requestedFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    fontFeatures: enableTnum ? const [FontFeature.tabularFigures()] : const [],
  );
}

double _measureTextWidth({
  required BuildContext context,
  required String value,
  required TextStyle style,
}) {
  final painter = TextPainter(
    text: TextSpan(text: value, style: style),
    textDirection: Directionality.of(context),
    maxLines: 1,
  )..layout();

  return painter.width;
}
