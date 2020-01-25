import 'package:meta/meta.dart';

import 'binary.dart';

@BinaryType(legacyFields: {2})
class MyClass<T> {
  MyClass({@required this.id, @required this.someNumbers});

  @BinaryField(0)
  final String id;

  @BinaryField(1)
  final Set<T> someNumbers;

  String toString() => 'MyClass($id, $someNumbers)';
}

class AdapterForMyClass<T> extends TypeAdapter<MyClass<T>> {
  const AdapterForMyClass();

  @override
  void write(BinaryWriter writer, MyClass<T> obj) {
    writer
      ..writeNumberOfFields(2)
      ..writeFieldId(0)
      ..write(obj.id)
      ..writeFieldId(1)
      ..write(obj.someNumbers);
  }

  @override
  MyClass<T> read(BinaryReader reader) {
    final numberOfFields = reader.readNumberOfFields();
    final fields = <int, dynamic>{
      for (var i = 0; i < numberOfFields; i++)
        reader.readFieldId(): reader.read(),
    };

    return MyClass<T>(
      id: fields[0],
      someNumbers: fields[1],
    );
  }
}

void main() {
  TypeRegistry
    ..registerLegacyTypes({1})
    ..registerAdapters({
      0: AdapterForMyClass<int>(),
    });

  final data = serialize(MyClass(
    id: 'hey',
    someNumbers: {1, 2},
  ));
  print('Serialized to $data');
  print(deserialize(data));
  print(data.map((byte) => byte.toRadixString(16)).join(' '));
}
