import 'dart:convert';
import 'dart:typed_data';

import '../../binary.dart';

import '../type_node.dart';
import '../type_registry.dart';

part 'big_int.dart';
part 'bool.dart';
part 'core.dart';
part 'custom.dart';
part 'int.dart';
part 'list.dart';
part 'map.dart';
part 'set.dart';
part 'string.dart';
part 'typed_data.dart';

void registerBuiltInAdapters(TypeRegistryImpl registry) {
  // Commonly used nodes should be registered first for more efficiency.
  registry.registerVirtualNode(AdapterNode<Iterable<dynamic>>.virtual());

  // dart:core adapters
  _registerCoreAdapters(registry);

  // dart:typed_data adapters
  _registerTypedDataAdapters(registry);
}

void _registerCoreAdapters(TypeRegistryImpl registry) {
  // null adapter
  registry
    ..registerAdapter(-101, const AdapterForNull())

  // int adapters
    ..registerVirtualNode(AdapterNode<int>.virtual())
    ..registerAdapters({
      -1: const AdapterForUint8(),
      -2: const AdapterForInt8(),
      -3: const AdapterForUint16(),
      -4: const AdapterForInt16(),
      -5: const AdapterForUint32(),
      -6: const AdapterForInt32(),
      -7: const AdapterForInt64(),
    })

  // double adapter
    ..registerAdapter(-8, const AdapterForDouble())

  // bool adapters
    ..registerVirtualNode(AdapterNode<bool>.virtual())
    ..registerAdapters({
      -9: const AdapterForTrueBool(),
      -10: const AdapterForFalseBool(),
    })

  // string adapters
    ..registerVirtualNode(AdapterNode<String>.virtual())
    ..registerAdapters({
      -11: const AdapterForNullTerminatedString(),
      -12: const AdapterForArbitraryString(),
    })

  // various other adapters for primitive types
    ..registerAdapters({
      -13: const AdapterForBigInt(),
      -14: const AdapterForDateTime(),
      -15: const AdapterForDuration(),
      -16: const AdapterForRegExp(),
      -17: const AdapterForRunes(),
      -18: const AdapterForStackTrace(),
    })

  // list adapters
    ..registerAdapters({
      -19: const AdapterForList<dynamic>(),
      -20: const AdapterForListOfNull(),
      -102: const AdapterForListOfBool(),
      -21: const AdapterForListOfNullableBool(),
    })
    ..registerVirtualNode(AdapterNode<List<String>>.virtual())
    ..registerAdapters({
      -22: const AdapterForPrimitiveList<String>.short(AdapterForArbitraryString()),
      -23: const AdapterForPrimitiveList<String>.long(AdapterForArbitraryString()),
      -24: const AdapterForPrimitiveList<String>.nullable(AdapterForArbitraryString()),
    })
    ..registerVirtualNode(AdapterNode<List<double>>.virtual())
    ..registerAdapters({
      -25: const AdapterForPrimitiveList.short(AdapterForDouble()),
      -26: const AdapterForPrimitiveList.long(AdapterForDouble()),
      -27: const AdapterForPrimitiveList.nullable(AdapterForDouble()),
    })
    ..registerVirtualNode(AdapterNode<List<int>>.virtual())
    ..registerAdapters({
      -28: const AdapterForPrimitiveList.short(AdapterForUint8()),
      -29: const AdapterForPrimitiveList.long(AdapterForUint8()),
      -30: const AdapterForPrimitiveList.nullable(AdapterForUint8()),
      -31: const AdapterForPrimitiveList.short(AdapterForInt8()),
      -32: const AdapterForPrimitiveList.long(AdapterForInt8()),
      -33: const AdapterForPrimitiveList.nullable(AdapterForInt8()),
      -34: const AdapterForPrimitiveList.short(AdapterForUint16()),
      -35: const AdapterForPrimitiveList.long(AdapterForUint16()),
      -36: const AdapterForPrimitiveList.nullable(AdapterForUint16()),
      -37: const AdapterForPrimitiveList.short(AdapterForInt16()),
      -38: const AdapterForPrimitiveList.long(AdapterForInt16()),
      -39: const AdapterForPrimitiveList.nullable(AdapterForInt16()),
      -40: const AdapterForPrimitiveList.short(AdapterForUint32()),
      -41: const AdapterForPrimitiveList.long(AdapterForUint32()),
      -42: const AdapterForPrimitiveList.nullable(AdapterForUint32()),
      -43: const AdapterForPrimitiveList.short(AdapterForInt32()),
      -44: const AdapterForPrimitiveList.long(AdapterForInt32()),
      -45: const AdapterForPrimitiveList.nullable(AdapterForInt32()),
      -46: const AdapterForPrimitiveList.short(AdapterForInt64()),
      -47: const AdapterForPrimitiveList.long(AdapterForInt64()),
      -48: const AdapterForPrimitiveList.nullable(AdapterForInt64()),
    })
    ..registerAdapters({
      -49: const AdapterForList<BigInt>(),
      -50: const AdapterForList<DateTime>(),
      -51: const AdapterForList<Duration>(),
      -52: const AdapterForList<RegExp>(),
      -53: const AdapterForList<Runes>(),
      -54: const AdapterForList<StackTrace>(),
    })

  // set adapters
    ..registerAdapters({
      -55: const AdapterForSet<dynamic>(),
      -56: const AdapterForSet<Null>(),
      -57: const AdapterForSet<bool>(),
      -58: const AdapterForSet<String>(),
      -59: const AdapterForSet<double>(),
      -60: const AdapterForSet<int>(),
      -61: const AdapterForSet<BigInt>(),
      -62: const AdapterForSet<DateTime>(),
      -63: const AdapterForSet<Duration>(),
      -64: const AdapterForSet<RegExp>(),
      -65: const AdapterForSet<Runes>(),
      -66: const AdapterForSet<StackTrace>(),
    })

  // map adapters
    ..registerAdapters({
      -67: const AdapterForMapEntry<dynamic, dynamic>(),
      -68: const AdapterForMap<dynamic, dynamic>(),
      -69: const AdapterForMap<String, dynamic>(),
      -70: const AdapterForMap<String, bool>(),
      -71: const AdapterForMap<String, String>(),
      -72: const AdapterForMap<String, double>(),
      -73: const AdapterForMap<String, int>(),
      -74: const AdapterForMap<String, BigInt>(),
      -75: const AdapterForMap<String, DateTime>(),
      -76: const AdapterForMap<String, Duration>(),
      -77: const AdapterForMap<double, dynamic>(),
      -78: const AdapterForMap<double, bool>(),
      -79: const AdapterForMap<double, String>(),
      -80: const AdapterForMap<double, double>(),
      -81: const AdapterForMap<double, int>(),
      -82: const AdapterForMap<double, BigInt>(),
      -83: const AdapterForMap<double, DateTime>(),
      -84: const AdapterForMap<double, Duration>(),
      -85: const AdapterForMap<int, dynamic>(),
      -86: const AdapterForMap<int, bool>(),
      -87: const AdapterForMap<int, String>(),
      -88: const AdapterForMap<int, double>(),
      -89: const AdapterForMap<int, int>(),
      -90: const AdapterForMap<int, BigInt>(),
      -91: const AdapterForMap<int, DateTime>(),
      -92: const AdapterForMap<int, Duration>(),
      -93: const AdapterForMap<BigInt, Null>(),
      -94: const AdapterForMap<BigInt, bool>(),
      -95: const AdapterForMap<BigInt, String>(),
      -96: const AdapterForMap<BigInt, double>(),
      -97: const AdapterForMap<BigInt, int>(),
      -98: const AdapterForMap<BigInt, BigInt>(),
      -99: const AdapterForMap<BigInt, DateTime>(),
      -100: const AdapterForMap<BigInt, Duration>(),
    });
}

void _registerTypedDataAdapters(TypeRegistryImpl registry) {
  registry.registerAdapters({
    -110: const AdapterForUint8List(),
  });
}
