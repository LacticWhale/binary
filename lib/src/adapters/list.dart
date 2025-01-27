part of 'adapters.dart';

/// Adapter for a list of arbitrary elements. Because these elements may have
/// subclasses, the type has to be encoded for every element.
class AdapterForList<T extends dynamic> extends AdapterFor<List<T>> {
  const AdapterForList() : super.primitive();

  @override
  void write(BinaryWriter writer, List<T> list) {
    writer.writeUint32(list.length);
    list.forEach(writer.write);
  }

  @override
  List<T> read(BinaryReader reader) {
    final length = reader.readUint32();
    return <T>[
      for (var i = 0; i < length; i++) reader.read<T>(),
    ];
  }
}

/// Adapter for a list of [bool]s. Obviously, they can be encoded quite
/// efficiently.
class AdapterForListOfBool extends AdapterFor<List<bool>> {
  const AdapterForListOfBool() : super.primitive();

  int _boolToBits(bool value) => value ? 1 : 0;
  bool _bitsToBool(int bits) => bits == 1;

  @override
  void write(BinaryWriter writer, List<bool> obj) {
    writer.writeUint32(obj.length);
    for (var i = 0; i < obj.length + 1; i+=8) {
      var byte = 0;
      for (var j = 0; j < 8; j++) {
        final index = i + j;

        if (index < obj.length) {
          byte <<= 1;
          byte |= _boolToBits(obj[index]);
        } else {
          byte <<= 1;
          // 0 bit encode the end of the sequence.
        }
      }
      writer.writeUint8(byte);
    }
  }

  @override
  List<bool> read(BinaryReader reader) {
    final list = <bool>[];

    final length = reader.readUint32();

    add: for (var i = 0; i < length + 1; i += 8) {
      final byte = reader.readUint8();
      for (var j = 7; j >= 0; j--) {
        final index = i + j;

        if(index < length)
          list.add(_bitsToBool(byte & 1 << i));
        else
          break add;
      }
    }
    
    return list;
  }
}

/// Adapter for a list of [bool]s. Obviously, they can be encoded quite
/// efficiently. Because the list may contain [null], the elements are encoded
/// as two bytes with 11 for [null], 01 for [true], 10 for [false] and 00 as a
/// terminating sequence.
class AdapterForListOfNullableBool extends AdapterFor<List<bool?>> {
  const AdapterForListOfNullableBool() : super.primitive();

  int _boolToBits(bool? value) => value == null ? 3 : value ? 1 : 2;
  bool? _bitsToBool(int bits) => bits == 3 ? null : bits == 1;

  @override
  void write(BinaryWriter writer, List<bool?> obj) {
    for (var i = 0; i < obj.length + 1; i += 4) {
      var byte = 0;
      for (var j = 0; j < 4; j++) {
        final index = i + j;
        if (index < obj.length) {
          byte <<= 2;
          byte |= _boolToBits(i + j < obj.length ? obj[i + j] : null);
        } else {
          byte <<= 2;
          // 00 bits encode the end of the sequence.
        }
      }
      writer.writeUint8(byte);
    }
  }

  @override
  List<bool?> read(BinaryReader reader) {
    final list = <bool?>[];

    int byte;
    late int bits;
    do {
      byte = reader.readUint8();

      for (var j = 0; j < 4; j++) {
        // Read the two left bits.
        bits = (byte & (128 + 64)) >> 6;
        byte <<= 2;
        if (bits == 0) {
          break;
        }
        list.add(_bitsToBool(bits));
      }
    } while (bits != 0);

    return list;
  }
}

/// Because elements of type [Null] can only have the value [null], encoding
/// the length of the list is sufficient to reconstruct it.
// ignore: prefer_void_to_null
class AdapterForListOfNull extends AdapterFor<List<Null>> {
  const AdapterForListOfNull() : super.primitive();

  @override
// ignore: prefer_void_to_null
  void write(BinaryWriter writer, List<Null> obj) =>
      writer.writeUint32(obj.length);

  @override
// ignore: prefer_void_to_null
  List<Null> read(BinaryReader reader) {
    final length = reader.readUint32();

    return List.filled(length, null);
  }
}

/// An adapter for a list of a primitive type that can have no subclasses (like
/// [int], [double], [String] etc). We are sure that the elements are of the
/// exact right type, so we can encode them directly. They may be [null]
/// though, so a bit field at the beginning encodes the null-ness of the
/// elements (as well as the length of the list).
class AdapterForPrimitiveList<T extends dynamic>
    extends AdapterForSpecificValueOfType<List<T?>> {
  const AdapterForPrimitiveList._({
    required this.isShort,
    required this.isNullable,
    required this.adapter,
  })  : super.primitive();

  const AdapterForPrimitiveList.short(AdapterFor<T> adapter)
      : this._(adapter: adapter, isNullable: false, isShort: true);

  const AdapterForPrimitiveList.long(AdapterFor<T> adapter)
      : this._(adapter: adapter, isNullable: false, isShort: false);

  const AdapterForPrimitiveList.nullable(AdapterFor<T> adapter)
      : this._(adapter: adapter, isNullable: true, isShort: false);

  final bool isShort;
  final bool isNullable;
  final AdapterFor<T> adapter;

  @override
  bool matches(List<T?> value) {
    if (isShort && value.length >= 256) 
      return false;
    if (!isNullable && value.any((item) => item == null)) 
      return false;
    if (adapter is! AdapterForSpecificValueOfType)
      return false;
    final valueAdapter = adapter as AdapterForSpecificValueOfType<T>;
    return value.where((item) => item != null).every((item) => valueAdapter.matches(item as T));
  }

  @override
  void write(BinaryWriter writer, List<T?> obj) {
    if (isNullable) {
      /// List of [true] if element exists or [false] if element doesn't exist.
      const AdapterForListOfBool()
          .write(writer, obj.map((element) => element != null).toList());
    } else {
      (isShort ? writer.writeUint8 : writer.writeUint32)(obj.length);
    }

    // Write the remaining non-null items.
    for (final item in obj.where((element) => element != null)) {
      adapter.write(writer, item as T);
    }
  }

  @override
  List<T?> read(BinaryReader reader) {
    int length;
    List<bool> existences;

    if (isNullable) {
      existences = const AdapterForListOfBool().read(reader);
      length = existences.length;
    } else {
      length = isShort ? reader.readUint8() : reader.readUint32();
      existences = <bool>[for (var i = 0; i < length; i++) true];
    }

    return <T?>[
      for (var i = 0; i < existences.length; i++)
        if (existences[i]) adapter.read(reader) else null,
    ];
  }
}
