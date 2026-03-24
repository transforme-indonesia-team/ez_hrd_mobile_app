class OrgEmployeeModel {
  final int? userId;
  final String? empName;
  final String? spvParent;
  final String? mgrParent;
  final String? empId;
  final String? empNo;
  final String? posName;
  final String? photo;
  final int? companyId;
  final String? spvPath;
  final String? mgrPath;
  final int? positionId;
  final String? companyName;
  final String? deptName;
  final String? worklocationName;
  final String? costcenterNameEn;
  final String? fullName;
  final String? orgLevel;
  final String? orgLevelName;

  OrgEmployeeModel({
    this.userId,
    this.empName,
    this.spvParent,
    this.mgrParent,
    this.empId,
    this.empNo,
    this.posName,
    this.photo,
    this.companyId,
    this.spvPath,
    this.mgrPath,
    this.positionId,
    this.companyName,
    this.deptName,
    this.worklocationName,
    this.costcenterNameEn,
    this.fullName,
    this.orgLevel,
    this.orgLevelName,
  });

  factory OrgEmployeeModel.fromJson(Map<String, dynamic> json) {
    return OrgEmployeeModel(
      userId: json['user_id'] as int?,
      empName: json['emp_name'] as String?,
      spvParent: json['spv_parent'] as String?,
      mgrParent: json['mgr_parent'] as String?,
      empId: json['emp_id'] as String?,
      empNo: json['emp_no'] as String?,
      posName: json['pos_name'] as String?,
      photo: json['photo'] as String?,
      companyId: json['company_id'] as int?,
      spvPath: json['spv_path'] as String?,
      mgrPath: json['mgr_path'] as String?,
      positionId: json['position_id'] as int?,
      companyName: json['company_name'] as String?,
      deptName: json['dept_name'] as String?,
      worklocationName: json['worklocation_name'] as String?,
      costcenterNameEn: json['costcenter_name_en'] as String?,
      fullName: json['full_name'] as String?,
      orgLevel: json['org_level'] as String?,
      orgLevelName: json['org_level_name'] as String?,
    );
  }
}

class OrgNodeModel {
  final String id;
  final String parentId;
  final String name;
  final String? deptId;
  final String? posFlag;
  final String? posCode;
  final int? companyId;
  final List<OrgEmployeeModel> employees;
  final String? orgLevel;
  final String? orgLevelName;
  final List<String> tags;

  // For graph UI logic
  bool isExpanded;
  List<OrgNodeModel> children;

  OrgNodeModel({
    required this.id,
    required this.parentId,
    required this.name,
    this.deptId,
    this.posFlag,
    this.posCode,
    this.companyId,
    this.employees = const [],
    this.orgLevel,
    this.orgLevelName,
    this.tags = const [],
    this.isExpanded = true,
    this.children = const [],
  });

  factory OrgNodeModel.fromJson(Map<String, dynamic> json) {
    var employeesList = json['employees'] as List? ?? [];
    List<OrgEmployeeModel> employees =
        employeesList.map((i) => OrgEmployeeModel.fromJson(i)).toList();

    var tagsList = json['tags'] as List? ?? [];
    List<String> tags = tagsList.map((e) => e.toString()).toList();

    return OrgNodeModel(
      id: json['id'].toString(),
      parentId: json['parent_id'].toString(),
      name: json['name']?.toString() ?? '',
      deptId: json['dept_id']?.toString(),
      posFlag: json['pos_flag']?.toString(),
      posCode: json['pos_code']?.toString(),
      companyId: json['company_id'] as int?,
      employees: employees,
      orgLevel: json['org_level']?.toString(),
      orgLevelName: json['org_level_name']?.toString(),
      tags: tags,
      isExpanded: true,
      children: [],
    );
  }

  // To help build the tree
  void addChild(OrgNodeModel child) {
    children.add(child);
  }
}
