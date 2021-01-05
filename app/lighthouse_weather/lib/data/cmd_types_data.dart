class CmdTypes {
  final _value;

  const CmdTypes._internal(this._value);

  get value => _value;

  static const UPDATE = const CmdTypes._internal('0');
  static const CITY = const CmdTypes._internal('1');
  static const COLOR = const CmdTypes._internal('2');
  static const IP = const CmdTypes._internal('3');
  static const SHUTDOWN = const CmdTypes._internal('9');

  toString() => 'Enum.$_value';
}