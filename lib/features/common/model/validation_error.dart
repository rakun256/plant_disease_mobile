class ValidationError {
  ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
    this.input,
    this.ctx,
  });

  final List<dynamic> loc;
  final String msg;
  final String type;
  final dynamic input;
  final Map<String, dynamic>? ctx;

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      loc: (json['loc'] as List<dynamic>? ?? const []),
      msg: json['msg'] as String? ?? '',
      type: json['type'] as String? ?? '',
      input: json['input'],
      ctx: json['ctx'] is Map<String, dynamic>
          ? json['ctx'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'loc': loc, 'msg': msg, 'type': type, 'input': input, 'ctx': ctx};
  }
}
