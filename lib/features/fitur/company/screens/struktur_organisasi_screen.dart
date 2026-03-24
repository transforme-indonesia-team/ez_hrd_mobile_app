import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/models/org_node_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─── Layout constants ────────────────────────────────────────────
const double _kNodeW = 200;
const double _kPersonW = 220;
const double _kBranch = 50;
const double _kRowGap = 28;
const double _kVertGap = 36;
const double _kTogglePad = 14; // space for toggle button below node

double _nodeW(OrgNodeModel n) =>
    (n.employees.length == 1 ? _kPersonW : _kNodeW).w;

double _nodeH(OrgNodeModel n) {
  if (n.id == "-1") return 100.h;
  if (n.employees.length > 1) return 90.h;
  if (n.employees.length == 1) return 70.h;
  return 52.h;
}

// Full card height including toggle button padding
double _cardH(OrgNodeModel n) =>
    _nodeH(n) + (n.children.isNotEmpty ? _kTogglePad.h : 0);

// ─── Layout result types ─────────────────────────────────────────
class _NL {
  final OrgNodeModel node;
  double x, y;
  final double w, h;
  _NL(this.node, this.x, this.y, this.w, this.h);
}

class _Seg {
  Offset a, b;
  _Seg(this.a, this.b);
}

class _Layout {
  final List<_NL> nodes;
  final List<_Seg> lines;
  final double w, h;
  _Layout(this.nodes, this.lines, this.w, this.h);
}

// ─── Subtree height ──────────────────────────────────────────────
double _treeH(OrgNodeModel node) {
  final ch = _cardH(node);
  if (!node.isExpanded || node.children.isEmpty) return ch;
  final ps = _pairs(node.children);
  double childrenH = 0;
  for (final p in ps) {
    final lh = _treeH(p[0]);
    final rh = p.length > 1 ? _treeH(p[1]) : 0.0;
    childrenH += math.max(lh, rh) + _kRowGap.h;
  }
  return ch + _kVertGap.h + childrenH;
}

List<List<OrgNodeModel>> _pairs(List<OrgNodeModel> c) {
  final r = <List<OrgNodeModel>>[];
  for (int i = 0; i < c.length; i += 2) {
    r.add(i + 1 < c.length ? [c[i], c[i + 1]] : [c[i]]);
  }
  return r;
}

// ─── Subtree extent calculation (for overlap prevention) ─────────
// How far a subtree extends RIGHT from node center
double _rExt(OrgNodeModel node) {
  final nw = _nodeW(node);
  if (!node.isExpanded || node.children.isEmpty) return nw / 2;
  final brW = _kBranch.w;
  double m = nw / 2;
  for (final p in _pairs(node.children)) {
    // Right children extend right
    if (p.length > 1) {
      final rnw = _nodeW(p[1]);
      m = math.max(m, brW + rnw / 2 + _rExt(p[1]));
    }
    // Left children might cross center via their right extent
    final lnw = _nodeW(p[0]);
    final crossRight = _rExt(p[0]) - brW - lnw / 2;
    if (crossRight > 0) m = math.max(m, crossRight);
  }
  return m;
}

// How far a subtree extends LEFT from node center
double _lExt(OrgNodeModel node) {
  final nw = _nodeW(node);
  if (!node.isExpanded || node.children.isEmpty) return nw / 2;
  final brW = _kBranch.w;
  double m = nw / 2;
  for (final p in _pairs(node.children)) {
    // Left children extend left
    final lnw = _nodeW(p[0]);
    m = math.max(m, brW + lnw / 2 + _lExt(p[0]));
    // Right children might cross center via their left extent
    if (p.length > 1) {
      final rnw = _nodeW(p[1]);
      final crossLeft = _lExt(p[1]) - brW - rnw / 2;
      if (crossLeft > 0) m = math.max(m, crossLeft);
    }
  }
  return m;
}

// ─── Place nodes recursively ─────────────────────────────────────
void _place(
  OrgNodeModel node,
  double cx,
  double ty,
  List<_NL> nodes,
  List<_Seg> lines,
) {
  final nw = _nodeW(node);
  final ch = _cardH(node);
  nodes.add(_NL(node, cx - nw / 2, ty, nw, ch));

  if (!node.isExpanded || node.children.isEmpty) return;

  final ps = _pairs(node.children);
  final spineX = cx;
  final brW = _kBranch.w;

  // ── Dynamic offset: prevent subtree overlap ──
  double maxLeftOff = 0;
  double maxRightOff = 0;
  for (final p in ps) {
    final lnw = _nodeW(p[0]);
    final lre = _rExt(p[0]); // left child's right extent from its center
    // Ensure left child's rightmost point stays left of spine (with 10.w gap)
    maxLeftOff = math.max(maxLeftOff, math.max(brW + lnw / 2, lre + 10.w));
    if (p.length > 1) {
      final rnw = _nodeW(p[1]);
      final rle = _lExt(p[1]); // right child's left extent from its center
      maxRightOff = math.max(maxRightOff, math.max(brW + rnw / 2, rle + 10.w));
    }
  }

  // Pre-compute connect Ys and row heights
  double curY = ty + ch + _kVertGap.h;
  final connectYs = <double>[];
  final rowHs = <double>[];

  for (final p in ps) {
    final lnh = _nodeH(p[0]);
    connectYs.add(curY + lnh / 2);
    final lh = _treeH(p[0]);
    final rh = p.length > 1 ? _treeH(p[1]) : 0.0;
    rowHs.add(math.max(lh, rh));
    curY += rowHs.last + _kRowGap.h;
  }

  // Vertical spine
  lines.add(_Seg(Offset(spineX, ty + ch), Offset(spineX, connectYs.last)));

  // Place each pair with dynamic offsets
  curY = ty + ch + _kVertGap.h;
  for (int i = 0; i < ps.length; i++) {
    final p = ps[i];

    // Left child
    final lnw = _nodeW(p[0]);
    final leftCx = spineX - maxLeftOff;
    final leftEdgeX = leftCx + lnw / 2; // node's right edge
    lines.add(
      _Seg(Offset(spineX, connectYs[i]), Offset(leftEdgeX, connectYs[i])),
    );
    _place(p[0], leftCx, curY, nodes, lines);

    // Right child — use same connectY as left for clean alignment
    if (p.length > 1) {
      final rnw = _nodeW(p[1]);
      final rightCx = spineX + maxRightOff;
      final rightEdgeX = rightCx - rnw / 2;
      lines.add(
        _Seg(Offset(spineX, connectYs[i]), Offset(rightEdgeX, connectYs[i])),
      );
      _place(p[1], rightCx, curY, nodes, lines);
    }

    curY += rowHs[i] + _kRowGap.h;
  }
}

// ─── Build layout with bounding-box normalization ────────────────
_Layout _buildLayout(OrgNodeModel root) {
  final nodes = <_NL>[];
  final lines = <_Seg>[];
  _place(root, 0, 0, nodes, lines);

  double minX = 0, maxX = 0, maxY = 0;
  for (final n in nodes) {
    minX = math.min(minX, n.x);
    maxX = math.max(maxX, n.x + n.w);
    maxY = math.max(maxY, n.y + n.h);
  }
  for (final l in lines) {
    minX = math.min(minX, math.min(l.a.dx, l.b.dx));
    maxX = math.max(maxX, math.max(l.a.dx, l.b.dx));
    maxY = math.max(maxY, math.max(l.a.dy, l.b.dy));
  }

  final dx = -minX + 20.w;
  for (final n in nodes) {
    n.x += dx;
  }
  for (final l in lines) {
    l.a = Offset(l.a.dx + dx, l.a.dy);
    l.b = Offset(l.b.dx + dx, l.b.dy);
  }

  return _Layout(nodes, lines, maxX - minX + 40.w, maxY + 20.h);
}

// ─── Line painter ────────────────────────────────────────────────
class _LinePainter extends CustomPainter {
  final List<_Seg> lines;
  _LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final s in lines) {
      canvas.drawLine(s.a, s.b, p);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════
class StrukturOrganisasiScreen extends StatefulWidget {
  const StrukturOrganisasiScreen({super.key});
  @override
  State<StrukturOrganisasiScreen> createState() =>
      _StrukturOrganisasiScreenState();
}

class _StrukturOrganisasiScreenState extends State<StrukturOrganisasiScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  OrgNodeModel? _rootNode;
  final Map<String, OrgNodeModel> _nodeMap = {};
  final Map<String, GlobalKey> _nodeKeys = {};
  final TransformationController _tc = TransformationController();
  late AnimationController _anim;
  Animation<Matrix4>? _matAnim;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 450),
        )..addListener(() {
          if (_matAnim != null) _tc.value = _matAnim!.value;
        });
    _loadData();
  }

  @override
  void dispose() {
    _anim.dispose();
    _tc.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Simulate API latency (remove when using real API)
      await Future.delayed(const Duration(seconds: 2));
      final raw = await rootBundle.loadString(
        'lib/data/dummy/org_structure_dummy.json',
      );
      final records = jsonDecode(raw)['data'] as List;
      final all = records.map((e) => OrgNodeModel.fromJson(e)).toList();

      for (var n in all) {
        n.isExpanded = false;
        _nodeMap[n.id] = n;
        _nodeKeys[n.id] = GlobalKey();
      }

      OrgNodeModel? root;
      for (var n in all) {
        if (n.parentId == "" || (n.parentId == "-1" && n.id == "-1")) {
          root = n;
        } else {
          _nodeMap[n.parentId]?.addChild(n);
          if (n.id == "-1" && root == null) root = n;
        }
      }
      for (var n in all) {
        if (n.parentId == "-1" && n.id != "-1") {
          final p = _nodeMap["-1"];
          if (p != null && !p.children.contains(n)) p.addChild(n);
        }
      }
      root ??= _nodeMap["-1"];
      root?.isExpanded = true;

      setState(() {
        _rootNode = root;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerGraph());
    } catch (e) {
      debugPrint("Err: $e");
      setState(() => _isLoading = false);
    }
  }

  void _toggleExpand(OrgNodeModel node) {
    if (node.children.isEmpty) return;
    final was = node.isExpanded;
    setState(() => node.isExpanded = !node.isExpanded);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!was) {
        _focusOnNode(node.id, expanding: true);
      } else if (node.parentId.isNotEmpty &&
          _nodeKeys.containsKey(node.parentId)) {
        _focusOnNode(node.parentId, expanding: false);
      } else {
        _overviewZoom();
      }
    });
  }

  void _focusOnNode(String id, {bool expanding = true}) {
    final k = _nodeKeys[id];
    if (k?.currentContext == null) return;
    final nb = k!.currentContext!.findRenderObject() as RenderBox?;
    final cb = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (nb == null || cb == null || !nb.hasSize) return;

    final np = nb.localToGlobal(Offset.zero) - cb.localToGlobal(Offset.zero);
    final cm = _tc.value;
    final cs = cm.getMaxScaleOnAxis();
    final ax = (np.dx - cm.storage[12]) / cs;
    final ay = (np.dy - cm.storage[13]) / cs;
    final nw = nb.size.width / cs, nh = nb.size.height / cs;

    final s = MediaQuery.of(context).size;
    final vpW = s.width, vpH = s.height - 160;
    final scale = expanding ? 1.4 : 0.9;
    final tx = vpW / 2 - (ax + nw / 2) * scale;
    final ty = (expanding ? vpH * 0.25 : vpH * 0.3) - (ay + nh / 2) * scale;
    _animTo(_mat(scale, tx, ty));
  }

  void _overviewZoom() {
    if (_rootNode == null) return;
    final lay = _buildLayout(_rootNode!);
    final s = MediaQuery.of(context).size;
    // Fit entire layout width on screen
    final scale = math.min(0.5, (s.width - 40) / lay.w);
    final tx = (s.width - lay.w * scale) / 2;
    _animTo(_mat(scale, tx, 20));
  }

  void _centerGraph() {
    if (_rootNode == null) return;
    final lay = _buildLayout(_rootNode!);
    final s = MediaQuery.of(context).size;
    final vpH = s.height - 160;
    final contentW = lay.w + 40.w;
    final contentH = lay.h + 40.w;
    final scaleW = s.width / contentW;
    final scaleH = vpH / contentH;
    // Fit to screen with slight zoom boost (1.15x)
    final scale = math.min(0.8, math.min(scaleW, scaleH)) * 1.15;
    final tx = (s.width - contentW * scale) / 2;
    final ty = (vpH - contentH * scale) / 2;
    _tc.value = _mat(scale, tx, math.max(8, ty));
  }

  void _zoomIn() => _zoomBy(1.3);
  void _zoomOut() => _zoomBy(0.7);

  void _zoomBy(double factor) {
    final cm = _tc.value;
    final cs = cm.getMaxScaleOnAxis();
    final ts = (cs * factor).clamp(0.05, 5.0);
    final s = MediaQuery.of(context).size;
    final fp = Offset(s.width / 2, s.height / 2);
    final sf = ts / cs;
    _animTo(
      _mat(
        ts,
        fp.dx * (1 - sf) + cm.storage[12] * sf,
        fp.dy * (1 - sf) + cm.storage[13] * sf,
      ),
    );
  }

  Matrix4 _mat(double s, double tx, double ty) {
    final m = Matrix4.identity();
    m.storage[0] = s;
    m.storage[5] = s;
    m.storage[12] = tx;
    m.storage[13] = ty;
    return m;
  }

  void _animTo(Matrix4 target) {
    _anim.reset();
    _matAnim = Matrix4Tween(
      begin: _tc.value,
      end: target,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic));
    _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Struktur Organisasi',
          style: AppTextStyles.h3(c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rootNode == null
          ? Center(
              child: Text(
                "Data tidak ditemukan",
                style: AppTextStyles.body(c.textPrimary),
              ),
            )
          : Column(
              children: [
                _toolbar(c),
                Expanded(
                  child: InteractiveViewer(
                    transformationController: _tc,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.05,
                    maxScale: 5.0,
                    child: Container(
                      key: _canvasKey,
                      padding: EdgeInsets.all(20.w),
                      child: _chart(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _toolbar(ThemeColors c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    color: Colors.white,
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: c.divider),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diagram Bagan',
                  style: AppTextStyles.bodyMedium(c.textPrimary),
                ),
                Icon(Icons.keyboard_arrow_down, color: c.textSecondary),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        IconButton(
          icon: Icon(Icons.zoom_in, color: c.textSecondary),
          onPressed: _zoomIn,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 16.w),
        IconButton(
          icon: Icon(Icons.zoom_out, color: c.textSecondary),
          onPressed: _zoomOut,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );

  Widget _chart() {
    final lay = _buildLayout(_rootNode!);
    return SizedBox(
      width: lay.w,
      height: lay.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _LinePainter(lay.lines))),
          for (final n in lay.nodes)
            Positioned(
              left: n.x,
              top: n.y,
              child: _NodeCard(
                node: n.node,
                nodeKey: _nodeKeys[n.node.id],
                onToggle: () => _toggleExpand(n.node),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NODE CARD — heights forced to match _nodeH estimates
// ═══════════════════════════════════════════════════════════════════
class _NodeCard extends StatelessWidget {
  final OrgNodeModel node;
  final GlobalKey? nodeKey;
  final VoidCallback onToggle;
  const _NodeCard({required this.node, this.nodeKey, required this.onToggle});

  bool get _hasKids => node.children.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: _hasKids ? _kTogglePad.h : 0),
          child: Container(key: nodeKey, child: _content()),
        ),
        if (_hasKids)
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Icon(
                  node.isExpanded ? Icons.remove : Icons.add,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _content() {
    if (node.id == "-1") return _root();
    if (node.employees.length > 1) return _group();
    if (node.employees.length == 1) return _person();
    return _dept();
  }

  Widget _root() => SizedBox(
    height: 100.h,
    width: _kNodeW.w,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            ),
            child: Text(
              node.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 40.h,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.business, size: 40),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dept() => SizedBox(
    height: 52.h,
    width: _kNodeW.w,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.r),
        border: Border(
          left: BorderSide(color: Colors.orange, width: 4.w),
        ),
      ),
      child: Center(
        child: Text(
          node.name,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  Widget _group() => SizedBox(
    height: 90.h,
    width: _kNodeW.w,
    child: Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            node.name,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              alignment: WrapAlignment.center,
              children: node.employees
                  .take(6)
                  .map((e) => _avatar(e.photo))
                  .toList(),
            ),
          ),
          if (node.employees.length > 6)
            Text(
              '+${node.employees.length - 6} lainnya',
              style: TextStyle(fontSize: 10.sp),
            ),
        ],
      ),
    ),
  );

  Widget _person() {
    final e = node.employees.first;
    return SizedBox(
      height: 70.h,
      width: _kPersonW.w,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(
            left: BorderSide(color: Colors.orange, width: 4.w),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _avatar(e.photo),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.fullName ?? e.empName ?? '-',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    e.posName ?? node.name,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? url) => Container(
    width: 36.w,
    height: 36.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey[300],
      border: Border.all(color: Colors.red, width: 1.5.w),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18.w),
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: "https://your-api-url.com/storage/$url",
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Icon(Icons.person, size: 20.sp, color: Colors.grey[600]),
            )
          : Icon(Icons.person, size: 20.sp, color: Colors.grey[600]),
    ),
  );
}
