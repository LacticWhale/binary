import 'package:binary/binary.dart';
import 'package:test/test.dart';

class MyClass {
  MyClass({
    required this.number1,
    required this.number2,
    required this.trueValue,
    required this.falseValue,
    required this.stringNullTerminated,
    required this.string1,
    required this.bigInt,
    required this.dateTime,
    required this.duration,
    required this.regExp,
    required this.runes,
  });
  
  
  final int number1;
  final double number2;
  final bool trueValue;
  final bool falseValue;
  final String stringNullTerminated;
  final String string1;
  final BigInt bigInt;
  final DateTime dateTime;
  final Duration duration;
  final RegExp regExp;
  final Runes runes;
}

class MyClassAdapter extends AdapterFor<MyClass> {
  @override
  MyClass read(BinaryReader reader) => MyClass(
    number1: reader.readInt32(), 
    number2: reader.read(), 
    trueValue: reader.read(), 
    falseValue: reader.read(), 
    stringNullTerminated: reader.read(), 
    string1: reader.read(), 
    bigInt: reader.read(), 
    dateTime: reader.read(), 
    duration: reader.read(), 
    regExp: reader.read(), 
    runes: reader.read(),
  );

  @override
  void write(BinaryWriter writer, MyClass obj) => writer
    ..writeInt32(obj.number1)
    ..write(obj.number2)
    ..write(obj.trueValue)
    ..write(obj.falseValue)
    ..write(obj.stringNullTerminated)
    ..write(obj.string1)
    ..write(obj.bigInt)
    ..write(obj.dateTime)
    ..write(obj.duration)
    ..write(obj.regExp)
    ..write(obj.runes);

}

void main() {
  MyClassAdapter().registerForId(1);
  const AdapterForList<int>().registerForId(2);
  const AdapterForList<String>().registerForId(3);


  group('Test serializing', () {
    group('integers', () {
      test('Uint8', () {
        const data = 126;
        final expected = [127, 255, 126];
        expect(
          binary.serialize(data), 
          equals(expected),
        );
      });
      test('Int8', () { 
        const data = -14;
        final expected = [127, 254, 242];
        
        expect(
          binary.serialize(data), 
          equals(expected),
        );
      });
      test('Uint16', () => 
        expect(
          binary.serialize(453), 
          equals([127, 253, 1, 197]),
        ),
      );
      test('Int16', () => 
        expect(
          binary.serialize(-453), 
          equals([127, 252, 254, 59]),
        ),
      );
      test('Uint32', () => 
        expect(
          binary.serialize(48438484), 
          equals([127, 251, 2, 227, 28, 212]),
        ),
      );
      test('Int32', () => 
        expect(
          binary.serialize(-48438484), 
          equals([127, 250, 253, 28, 227, 44]),
        ),
      );
      test('Int64', () => 
        expect(
          binary.serialize(-3232323223939238282), 
          equals([127, 249, 211, 36, 123, 39, 69, 219, 54, 118]),
        ),
      );
    });

    test('Double', () => 
      expect(
        binary.serialize(0.123), 
        equals([127, 248, 63, 191, 124, 237, 145, 104, 114, 176]),
      ),
    );

    group('booleans', () {
      test('True', () => 
        expect(
          binary.serialize(true), 
          equals([127, 247]),
        ),
      );
      test('False', () => 
        expect(
          binary.serialize(false), 
          equals([127, 246]),
        ),
      );
    });

    group('Strings', () {
      test('Null terminated string', () => 
        expect(
          binary.serialize('Some st\0ring.'), 
          equals([127, 245, 83, 111, 109, 101, 32, 115, 116, 48, 114, 105, 110, 103, 46, 0]),
        ),
      );
      test('Arbitrary string', () => 
        expect(
          binary.serialize('Another string.'), 
          equals([127, 244, 0, 0, 0, 15, 65, 110, 111, 116, 104, 101, 114, 32, 115, 116, 114, 105, 110, 103, 46]),
        ),
      );
    });

    group('Primitive types', () {
      test('BigInt', () => 
        expect(
          binary.serialize(BigInt.from(1)), 
          equals([127, 243, 0, 0, 0, 2, 64]),
        ),
      );
      test('DateTime', () => 
        expect(
          binary.serialize(DateTime.fromMillisecondsSinceEpoch(1640979000000)),
          equals([127, 242, 0, 5, 212, 118, 50, 96, 254, 0]),
        ),
      );
      test('Duration', () => 
        expect(
          binary.serialize(const Duration(seconds: 123)), 
          equals([127, 241, 0, 0, 0, 0, 7, 84, 212, 192]),
        ),
      );
      test('ReqExp', () => 
        expect(
          binary.serialize(RegExp(r'(\w+)')),
          equals([127, 240, 0, 0, 0, 11, 40, 92, 119, 43, 41, 0, 0, 0, 0, 4, 128]),
        ),
      );
      test('Runes', () => 
        expect(
          binary.serialize(Runes('string')), 
          equals([127, 239, 115, 116, 114, 105, 110, 103, 0]),
        ),
      );
      // TODO: test StackTrace
    });

    group('Lists', () {
      // Work for booleans work for others, right?
      test('Bools', () {
        expect(
          binary.serialize([true, false, true, false, false]),
          equals([127, 154, 0, 0, 0, 5, 160 /* 10100000 */]),
        );
      });

      test('Nullable bools', () {
        expect(
          binary.serialize([true, null, null, false, false, false, true]), 
          equals([127, 235, 126 /* 01111110 */, 164 /* 10100100 */ ]),
        );
      });
    });

    group('Sets', () {
      // Work for integers work for others, right? x2
      const AdapterForSet<int>().registerForId(4);
      test('Integers', () {
        expect(
          binary.serialize({1, 2}), 
          equals([128, 4, 128, 2, 0, 0, 0, 2, 127, 255, 1, 127, 255, 2]),
        );
      });
    });

    group('Maps', () {
      // Work for integers work for others, right? x3
      const AdapterForMap<String, int>().registerForId(5);
      test('Integers', () {
        expect(
          binary.serialize({
            '1': 1,
          }), 
          equals([
            128,
            5,
            128,
            3,
            0,
            0,
            0,
            1,
            127,
            244,
            0,
            0,
            0,
            1,
            49,
            128,
            2,
            0,
            0,
            0,
            1,
            127,
            255,
            1
          ]),
        );
      });
    });

  });

}
