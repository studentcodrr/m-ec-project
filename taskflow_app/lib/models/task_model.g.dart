// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      listId: fields[3] as String,
      isCompleted: fields[4] as bool,
      createdBy: fields[5] as String,
      deadline: fields[6] as DateTime,
      assignedTo: (fields[7] as List).cast<String>(),
      teamName: fields[8] as String,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.listId)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.createdBy)
      ..writeByte(6)
      ..write(obj.deadline)
      ..writeByte(7)
      ..write(obj.assignedTo)
      ..writeByte(8)
      ..write(obj.teamName)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
