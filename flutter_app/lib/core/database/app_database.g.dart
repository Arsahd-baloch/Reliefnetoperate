// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalTasksTable extends LocalTasks
    with TableInfo<$LocalTasksTable, LocalTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _campaignIdMeta =
      const VerificationMeta('campaignId');
  @override
  late final GeneratedColumn<int> campaignId = GeneratedColumn<int>(
      'campaign_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<int> beneficiaryId = GeneratedColumn<int>(
      'beneficiary_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
      'created_by', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _claimedByMeta =
      const VerificationMeta('claimedBy');
  @override
  late final GeneratedColumn<int> claimedBy = GeneratedColumn<int>(
      'claimed_by', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _coordinatorIdMeta =
      const VerificationMeta('coordinatorId');
  @override
  late final GeneratedColumn<int> coordinatorId = GeneratedColumn<int>(
      'coordinator_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _familySizeMeta =
      const VerificationMeta('familySize');
  @override
  late final GeneratedColumn<int> familySize = GeneratedColumn<int>(
      'family_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _itemsNeededMeta =
      const VerificationMeta('itemsNeeded');
  @override
  late final GeneratedColumn<String> itemsNeeded = GeneratedColumn<String>(
      'items_needed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationTextMeta =
      const VerificationMeta('locationText');
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
      'location_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _radiusKmMeta =
      const VerificationMeta('radiusKm');
  @override
  late final GeneratedColumn<int> radiusKm = GeneratedColumn<int>(
      'radius_km', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _budgetPkrMeta =
      const VerificationMeta('budgetPkr');
  @override
  late final GeneratedColumn<double> budgetPkr = GeneratedColumn<double>(
      'budget_pkr', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _urgencyMeta =
      const VerificationMeta('urgency');
  @override
  late final GeneratedColumn<String> urgency = GeneratedColumn<String>(
      'urgency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _upvotesMeta =
      const VerificationMeta('upvotes');
  @override
  late final GeneratedColumn<int> upvotes = GeneratedColumn<int>(
      'upvotes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _downvotesMeta =
      const VerificationMeta('downvotes');
  @override
  late final GeneratedColumn<int> downvotes = GeneratedColumn<int>(
      'downvotes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _viewCountMeta =
      const VerificationMeta('viewCount');
  @override
  late final GeneratedColumn<int> viewCount = GeneratedColumn<int>(
      'view_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claimedAtMeta =
      const VerificationMeta('claimedAt');
  @override
  late final GeneratedColumn<String> claimedAt = GeneratedColumn<String>(
      'claimed_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        campaignId,
        beneficiaryId,
        createdBy,
        claimedBy,
        coordinatorId,
        sourceType,
        title,
        description,
        category,
        familySize,
        itemsNeeded,
        latitude,
        longitude,
        locationText,
        radiusKm,
        budgetPkr,
        urgency,
        status,
        upvotes,
        downvotes,
        viewCount,
        createdAt,
        updatedAt,
        claimedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
          _campaignIdMeta,
          campaignId.isAcceptableOrUnknown(
              data['campaign_id']!, _campaignIdMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('claimed_by')) {
      context.handle(_claimedByMeta,
          claimedBy.isAcceptableOrUnknown(data['claimed_by']!, _claimedByMeta));
    }
    if (data.containsKey('coordinator_id')) {
      context.handle(
          _coordinatorIdMeta,
          coordinatorId.isAcceptableOrUnknown(
              data['coordinator_id']!, _coordinatorIdMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('family_size')) {
      context.handle(
          _familySizeMeta,
          familySize.isAcceptableOrUnknown(
              data['family_size']!, _familySizeMeta));
    }
    if (data.containsKey('items_needed')) {
      context.handle(
          _itemsNeededMeta,
          itemsNeeded.isAcceptableOrUnknown(
              data['items_needed']!, _itemsNeededMeta));
    } else if (isInserting) {
      context.missing(_itemsNeededMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('location_text')) {
      context.handle(
          _locationTextMeta,
          locationText.isAcceptableOrUnknown(
              data['location_text']!, _locationTextMeta));
    }
    if (data.containsKey('radius_km')) {
      context.handle(_radiusKmMeta,
          radiusKm.isAcceptableOrUnknown(data['radius_km']!, _radiusKmMeta));
    }
    if (data.containsKey('budget_pkr')) {
      context.handle(_budgetPkrMeta,
          budgetPkr.isAcceptableOrUnknown(data['budget_pkr']!, _budgetPkrMeta));
    }
    if (data.containsKey('urgency')) {
      context.handle(_urgencyMeta,
          urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta));
    } else if (isInserting) {
      context.missing(_urgencyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('upvotes')) {
      context.handle(_upvotesMeta,
          upvotes.isAcceptableOrUnknown(data['upvotes']!, _upvotesMeta));
    }
    if (data.containsKey('downvotes')) {
      context.handle(_downvotesMeta,
          downvotes.isAcceptableOrUnknown(data['downvotes']!, _downvotesMeta));
    }
    if (data.containsKey('view_count')) {
      context.handle(_viewCountMeta,
          viewCount.isAcceptableOrUnknown(data['view_count']!, _viewCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('claimed_at')) {
      context.handle(_claimedAtMeta,
          claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      campaignId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}campaign_id']),
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}beneficiary_id']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_by']),
      claimedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}claimed_by']),
      coordinatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coordinator_id']),
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      familySize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}family_size'])!,
      itemsNeeded: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items_needed'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      locationText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_text']),
      radiusKm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}radius_km'])!,
      budgetPkr: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}budget_pkr'])!,
      urgency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}urgency'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      upvotes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}upvotes'])!,
      downvotes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downvotes'])!,
      viewCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}view_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at']),
      claimedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}claimed_at']),
    );
  }

  @override
  $LocalTasksTable createAlias(String alias) {
    return $LocalTasksTable(attachedDatabase, alias);
  }
}

class LocalTask extends DataClass implements Insertable<LocalTask> {
  final int id;
  final int? campaignId;
  final int? beneficiaryId;
  final int? createdBy;
  final int? claimedBy;
  final int? coordinatorId;
  final String sourceType;
  final String title;
  final String? description;
  final String? category;
  final int familySize;
  final String itemsNeeded;
  final double? latitude;
  final double? longitude;
  final String? locationText;
  final int radiusKm;
  final double budgetPkr;
  final String urgency;
  final String status;
  final int upvotes;
  final int downvotes;
  final int viewCount;
  final String? createdAt;
  final String? updatedAt;
  final String? claimedAt;
  const LocalTask(
      {required this.id,
      this.campaignId,
      this.beneficiaryId,
      this.createdBy,
      this.claimedBy,
      this.coordinatorId,
      required this.sourceType,
      required this.title,
      this.description,
      this.category,
      required this.familySize,
      required this.itemsNeeded,
      this.latitude,
      this.longitude,
      this.locationText,
      required this.radiusKm,
      required this.budgetPkr,
      required this.urgency,
      required this.status,
      required this.upvotes,
      required this.downvotes,
      required this.viewCount,
      this.createdAt,
      this.updatedAt,
      this.claimedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || campaignId != null) {
      map['campaign_id'] = Variable<int>(campaignId);
    }
    if (!nullToAbsent || beneficiaryId != null) {
      map['beneficiary_id'] = Variable<int>(beneficiaryId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<int>(createdBy);
    }
    if (!nullToAbsent || claimedBy != null) {
      map['claimed_by'] = Variable<int>(claimedBy);
    }
    if (!nullToAbsent || coordinatorId != null) {
      map['coordinator_id'] = Variable<int>(coordinatorId);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['family_size'] = Variable<int>(familySize);
    map['items_needed'] = Variable<String>(itemsNeeded);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationText != null) {
      map['location_text'] = Variable<String>(locationText);
    }
    map['radius_km'] = Variable<int>(radiusKm);
    map['budget_pkr'] = Variable<double>(budgetPkr);
    map['urgency'] = Variable<String>(urgency);
    map['status'] = Variable<String>(status);
    map['upvotes'] = Variable<int>(upvotes);
    map['downvotes'] = Variable<int>(downvotes);
    map['view_count'] = Variable<int>(viewCount);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || claimedAt != null) {
      map['claimed_at'] = Variable<String>(claimedAt);
    }
    return map;
  }

  LocalTasksCompanion toCompanion(bool nullToAbsent) {
    return LocalTasksCompanion(
      id: Value(id),
      campaignId: campaignId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaignId),
      beneficiaryId: beneficiaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaryId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      claimedBy: claimedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(claimedBy),
      coordinatorId: coordinatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinatorId),
      sourceType: Value(sourceType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      familySize: Value(familySize),
      itemsNeeded: Value(itemsNeeded),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationText: locationText == null && nullToAbsent
          ? const Value.absent()
          : Value(locationText),
      radiusKm: Value(radiusKm),
      budgetPkr: Value(budgetPkr),
      urgency: Value(urgency),
      status: Value(status),
      upvotes: Value(upvotes),
      downvotes: Value(downvotes),
      viewCount: Value(viewCount),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      claimedAt: claimedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(claimedAt),
    );
  }

  factory LocalTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTask(
      id: serializer.fromJson<int>(json['id']),
      campaignId: serializer.fromJson<int?>(json['campaignId']),
      beneficiaryId: serializer.fromJson<int?>(json['beneficiaryId']),
      createdBy: serializer.fromJson<int?>(json['createdBy']),
      claimedBy: serializer.fromJson<int?>(json['claimedBy']),
      coordinatorId: serializer.fromJson<int?>(json['coordinatorId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      familySize: serializer.fromJson<int>(json['familySize']),
      itemsNeeded: serializer.fromJson<String>(json['itemsNeeded']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationText: serializer.fromJson<String?>(json['locationText']),
      radiusKm: serializer.fromJson<int>(json['radiusKm']),
      budgetPkr: serializer.fromJson<double>(json['budgetPkr']),
      urgency: serializer.fromJson<String>(json['urgency']),
      status: serializer.fromJson<String>(json['status']),
      upvotes: serializer.fromJson<int>(json['upvotes']),
      downvotes: serializer.fromJson<int>(json['downvotes']),
      viewCount: serializer.fromJson<int>(json['viewCount']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      claimedAt: serializer.fromJson<String?>(json['claimedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'campaignId': serializer.toJson<int?>(campaignId),
      'beneficiaryId': serializer.toJson<int?>(beneficiaryId),
      'createdBy': serializer.toJson<int?>(createdBy),
      'claimedBy': serializer.toJson<int?>(claimedBy),
      'coordinatorId': serializer.toJson<int?>(coordinatorId),
      'sourceType': serializer.toJson<String>(sourceType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
      'familySize': serializer.toJson<int>(familySize),
      'itemsNeeded': serializer.toJson<String>(itemsNeeded),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationText': serializer.toJson<String?>(locationText),
      'radiusKm': serializer.toJson<int>(radiusKm),
      'budgetPkr': serializer.toJson<double>(budgetPkr),
      'urgency': serializer.toJson<String>(urgency),
      'status': serializer.toJson<String>(status),
      'upvotes': serializer.toJson<int>(upvotes),
      'downvotes': serializer.toJson<int>(downvotes),
      'viewCount': serializer.toJson<int>(viewCount),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'claimedAt': serializer.toJson<String?>(claimedAt),
    };
  }

  LocalTask copyWith(
          {int? id,
          Value<int?> campaignId = const Value.absent(),
          Value<int?> beneficiaryId = const Value.absent(),
          Value<int?> createdBy = const Value.absent(),
          Value<int?> claimedBy = const Value.absent(),
          Value<int?> coordinatorId = const Value.absent(),
          String? sourceType,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> category = const Value.absent(),
          int? familySize,
          String? itemsNeeded,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> locationText = const Value.absent(),
          int? radiusKm,
          double? budgetPkr,
          String? urgency,
          String? status,
          int? upvotes,
          int? downvotes,
          int? viewCount,
          Value<String?> createdAt = const Value.absent(),
          Value<String?> updatedAt = const Value.absent(),
          Value<String?> claimedAt = const Value.absent()}) =>
      LocalTask(
        id: id ?? this.id,
        campaignId: campaignId.present ? campaignId.value : this.campaignId,
        beneficiaryId:
            beneficiaryId.present ? beneficiaryId.value : this.beneficiaryId,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        claimedBy: claimedBy.present ? claimedBy.value : this.claimedBy,
        coordinatorId:
            coordinatorId.present ? coordinatorId.value : this.coordinatorId,
        sourceType: sourceType ?? this.sourceType,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        category: category.present ? category.value : this.category,
        familySize: familySize ?? this.familySize,
        itemsNeeded: itemsNeeded ?? this.itemsNeeded,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        locationText:
            locationText.present ? locationText.value : this.locationText,
        radiusKm: radiusKm ?? this.radiusKm,
        budgetPkr: budgetPkr ?? this.budgetPkr,
        urgency: urgency ?? this.urgency,
        status: status ?? this.status,
        upvotes: upvotes ?? this.upvotes,
        downvotes: downvotes ?? this.downvotes,
        viewCount: viewCount ?? this.viewCount,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        claimedAt: claimedAt.present ? claimedAt.value : this.claimedAt,
      );
  LocalTask copyWithCompanion(LocalTasksCompanion data) {
    return LocalTask(
      id: data.id.present ? data.id.value : this.id,
      campaignId:
          data.campaignId.present ? data.campaignId.value : this.campaignId,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      claimedBy: data.claimedBy.present ? data.claimedBy.value : this.claimedBy,
      coordinatorId: data.coordinatorId.present
          ? data.coordinatorId.value
          : this.coordinatorId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      familySize:
          data.familySize.present ? data.familySize.value : this.familySize,
      itemsNeeded:
          data.itemsNeeded.present ? data.itemsNeeded.value : this.itemsNeeded,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationText: data.locationText.present
          ? data.locationText.value
          : this.locationText,
      radiusKm: data.radiusKm.present ? data.radiusKm.value : this.radiusKm,
      budgetPkr: data.budgetPkr.present ? data.budgetPkr.value : this.budgetPkr,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      status: data.status.present ? data.status.value : this.status,
      upvotes: data.upvotes.present ? data.upvotes.value : this.upvotes,
      downvotes: data.downvotes.present ? data.downvotes.value : this.downvotes,
      viewCount: data.viewCount.present ? data.viewCount.value : this.viewCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTask(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('createdBy: $createdBy, ')
          ..write('claimedBy: $claimedBy, ')
          ..write('coordinatorId: $coordinatorId, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('familySize: $familySize, ')
          ..write('itemsNeeded: $itemsNeeded, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationText: $locationText, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('budgetPkr: $budgetPkr, ')
          ..write('urgency: $urgency, ')
          ..write('status: $status, ')
          ..write('upvotes: $upvotes, ')
          ..write('downvotes: $downvotes, ')
          ..write('viewCount: $viewCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        campaignId,
        beneficiaryId,
        createdBy,
        claimedBy,
        coordinatorId,
        sourceType,
        title,
        description,
        category,
        familySize,
        itemsNeeded,
        latitude,
        longitude,
        locationText,
        radiusKm,
        budgetPkr,
        urgency,
        status,
        upvotes,
        downvotes,
        viewCount,
        createdAt,
        updatedAt,
        claimedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTask &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.beneficiaryId == this.beneficiaryId &&
          other.createdBy == this.createdBy &&
          other.claimedBy == this.claimedBy &&
          other.coordinatorId == this.coordinatorId &&
          other.sourceType == this.sourceType &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.familySize == this.familySize &&
          other.itemsNeeded == this.itemsNeeded &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationText == this.locationText &&
          other.radiusKm == this.radiusKm &&
          other.budgetPkr == this.budgetPkr &&
          other.urgency == this.urgency &&
          other.status == this.status &&
          other.upvotes == this.upvotes &&
          other.downvotes == this.downvotes &&
          other.viewCount == this.viewCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.claimedAt == this.claimedAt);
}

class LocalTasksCompanion extends UpdateCompanion<LocalTask> {
  final Value<int> id;
  final Value<int?> campaignId;
  final Value<int?> beneficiaryId;
  final Value<int?> createdBy;
  final Value<int?> claimedBy;
  final Value<int?> coordinatorId;
  final Value<String> sourceType;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> category;
  final Value<int> familySize;
  final Value<String> itemsNeeded;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> locationText;
  final Value<int> radiusKm;
  final Value<double> budgetPkr;
  final Value<String> urgency;
  final Value<String> status;
  final Value<int> upvotes;
  final Value<int> downvotes;
  final Value<int> viewCount;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<String?> claimedAt;
  const LocalTasksCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.claimedBy = const Value.absent(),
    this.coordinatorId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.familySize = const Value.absent(),
    this.itemsNeeded = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationText = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.budgetPkr = const Value.absent(),
    this.urgency = const Value.absent(),
    this.status = const Value.absent(),
    this.upvotes = const Value.absent(),
    this.downvotes = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.claimedAt = const Value.absent(),
  });
  LocalTasksCompanion.insert({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.claimedBy = const Value.absent(),
    this.coordinatorId = const Value.absent(),
    required String sourceType,
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.familySize = const Value.absent(),
    required String itemsNeeded,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationText = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.budgetPkr = const Value.absent(),
    required String urgency,
    required String status,
    this.upvotes = const Value.absent(),
    this.downvotes = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.claimedAt = const Value.absent(),
  })  : sourceType = Value(sourceType),
        title = Value(title),
        itemsNeeded = Value(itemsNeeded),
        urgency = Value(urgency),
        status = Value(status);
  static Insertable<LocalTask> custom({
    Expression<int>? id,
    Expression<int>? campaignId,
    Expression<int>? beneficiaryId,
    Expression<int>? createdBy,
    Expression<int>? claimedBy,
    Expression<int>? coordinatorId,
    Expression<String>? sourceType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<int>? familySize,
    Expression<String>? itemsNeeded,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? locationText,
    Expression<int>? radiusKm,
    Expression<double>? budgetPkr,
    Expression<String>? urgency,
    Expression<String>? status,
    Expression<int>? upvotes,
    Expression<int>? downvotes,
    Expression<int>? viewCount,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? claimedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (createdBy != null) 'created_by': createdBy,
      if (claimedBy != null) 'claimed_by': claimedBy,
      if (coordinatorId != null) 'coordinator_id': coordinatorId,
      if (sourceType != null) 'source_type': sourceType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (familySize != null) 'family_size': familySize,
      if (itemsNeeded != null) 'items_needed': itemsNeeded,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationText != null) 'location_text': locationText,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (budgetPkr != null) 'budget_pkr': budgetPkr,
      if (urgency != null) 'urgency': urgency,
      if (status != null) 'status': status,
      if (upvotes != null) 'upvotes': upvotes,
      if (downvotes != null) 'downvotes': downvotes,
      if (viewCount != null) 'view_count': viewCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (claimedAt != null) 'claimed_at': claimedAt,
    });
  }

  LocalTasksCompanion copyWith(
      {Value<int>? id,
      Value<int?>? campaignId,
      Value<int?>? beneficiaryId,
      Value<int?>? createdBy,
      Value<int?>? claimedBy,
      Value<int?>? coordinatorId,
      Value<String>? sourceType,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? category,
      Value<int>? familySize,
      Value<String>? itemsNeeded,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? locationText,
      Value<int>? radiusKm,
      Value<double>? budgetPkr,
      Value<String>? urgency,
      Value<String>? status,
      Value<int>? upvotes,
      Value<int>? downvotes,
      Value<int>? viewCount,
      Value<String?>? createdAt,
      Value<String?>? updatedAt,
      Value<String?>? claimedAt}) {
    return LocalTasksCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      createdBy: createdBy ?? this.createdBy,
      claimedBy: claimedBy ?? this.claimedBy,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      familySize: familySize ?? this.familySize,
      itemsNeeded: itemsNeeded ?? this.itemsNeeded,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationText: locationText ?? this.locationText,
      radiusKm: radiusKm ?? this.radiusKm,
      budgetPkr: budgetPkr ?? this.budgetPkr,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<int>(campaignId.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<int>(beneficiaryId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (claimedBy.present) {
      map['claimed_by'] = Variable<int>(claimedBy.value);
    }
    if (coordinatorId.present) {
      map['coordinator_id'] = Variable<int>(coordinatorId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (familySize.present) {
      map['family_size'] = Variable<int>(familySize.value);
    }
    if (itemsNeeded.present) {
      map['items_needed'] = Variable<String>(itemsNeeded.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (radiusKm.present) {
      map['radius_km'] = Variable<int>(radiusKm.value);
    }
    if (budgetPkr.present) {
      map['budget_pkr'] = Variable<double>(budgetPkr.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<String>(urgency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (upvotes.present) {
      map['upvotes'] = Variable<int>(upvotes.value);
    }
    if (downvotes.present) {
      map['downvotes'] = Variable<int>(downvotes.value);
    }
    if (viewCount.present) {
      map['view_count'] = Variable<int>(viewCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<String>(claimedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTasksCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('createdBy: $createdBy, ')
          ..write('claimedBy: $claimedBy, ')
          ..write('coordinatorId: $coordinatorId, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('familySize: $familySize, ')
          ..write('itemsNeeded: $itemsNeeded, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationText: $locationText, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('budgetPkr: $budgetPkr, ')
          ..write('urgency: $urgency, ')
          ..write('status: $status, ')
          ..write('upvotes: $upvotes, ')
          ..write('downvotes: $downvotes, ')
          ..write('viewCount: $viewCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, action, payload, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int id;
  final String action;
  final String payload;
  final String status;
  final DateTime createdAt;
  const OutboxEntry(
      {required this.id,
      required this.action,
      required this.payload,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      action: Value(action),
      payload: Value(payload),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxEntry copyWith(
          {int? id,
          String? action,
          String? payload,
          String? status,
          DateTime? createdAt}) =>
      OutboxEntry(
        id: id ?? this.id,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, action, payload, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> id;
  final Value<String> action;
  final Value<String> payload;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    required String payload,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : action = Value(action),
        payload = Value(payload);
  static Insertable<OutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? action,
      Value<String>? payload,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalTasksTable localTasks = $LocalTasksTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localTasks, outboxEntries];
}

typedef $$LocalTasksTableCreateCompanionBuilder = LocalTasksCompanion Function({
  Value<int> id,
  Value<int?> campaignId,
  Value<int?> beneficiaryId,
  Value<int?> createdBy,
  Value<int?> claimedBy,
  Value<int?> coordinatorId,
  required String sourceType,
  required String title,
  Value<String?> description,
  Value<String?> category,
  Value<int> familySize,
  required String itemsNeeded,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> locationText,
  Value<int> radiusKm,
  Value<double> budgetPkr,
  required String urgency,
  required String status,
  Value<int> upvotes,
  Value<int> downvotes,
  Value<int> viewCount,
  Value<String?> createdAt,
  Value<String?> updatedAt,
  Value<String?> claimedAt,
});
typedef $$LocalTasksTableUpdateCompanionBuilder = LocalTasksCompanion Function({
  Value<int> id,
  Value<int?> campaignId,
  Value<int?> beneficiaryId,
  Value<int?> createdBy,
  Value<int?> claimedBy,
  Value<int?> coordinatorId,
  Value<String> sourceType,
  Value<String> title,
  Value<String?> description,
  Value<String?> category,
  Value<int> familySize,
  Value<String> itemsNeeded,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> locationText,
  Value<int> radiusKm,
  Value<double> budgetPkr,
  Value<String> urgency,
  Value<String> status,
  Value<int> upvotes,
  Value<int> downvotes,
  Value<int> viewCount,
  Value<String?> createdAt,
  Value<String?> updatedAt,
  Value<String?> claimedAt,
});

class $$LocalTasksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get claimedBy => $composableBuilder(
      column: $table.claimedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coordinatorId => $composableBuilder(
      column: $table.coordinatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get familySize => $composableBuilder(
      column: $table.familySize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemsNeeded => $composableBuilder(
      column: $table.itemsNeeded, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationText => $composableBuilder(
      column: $table.locationText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get radiusKm => $composableBuilder(
      column: $table.radiusKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budgetPkr => $composableBuilder(
      column: $table.budgetPkr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get urgency => $composableBuilder(
      column: $table.urgency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get upvotes => $composableBuilder(
      column: $table.upvotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downvotes => $composableBuilder(
      column: $table.downvotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get viewCount => $composableBuilder(
      column: $table.viewCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claimedAt => $composableBuilder(
      column: $table.claimedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get claimedBy => $composableBuilder(
      column: $table.claimedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coordinatorId => $composableBuilder(
      column: $table.coordinatorId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get familySize => $composableBuilder(
      column: $table.familySize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemsNeeded => $composableBuilder(
      column: $table.itemsNeeded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationText => $composableBuilder(
      column: $table.locationText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get radiusKm => $composableBuilder(
      column: $table.radiusKm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budgetPkr => $composableBuilder(
      column: $table.budgetPkr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get urgency => $composableBuilder(
      column: $table.urgency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get upvotes => $composableBuilder(
      column: $table.upvotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downvotes => $composableBuilder(
      column: $table.downvotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get viewCount => $composableBuilder(
      column: $table.viewCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claimedAt => $composableBuilder(
      column: $table.claimedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => column);

  GeneratedColumn<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get claimedBy =>
      $composableBuilder(column: $table.claimedBy, builder: (column) => column);

  GeneratedColumn<int> get coordinatorId => $composableBuilder(
      column: $table.coordinatorId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get familySize => $composableBuilder(
      column: $table.familySize, builder: (column) => column);

  GeneratedColumn<String> get itemsNeeded => $composableBuilder(
      column: $table.itemsNeeded, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get locationText => $composableBuilder(
      column: $table.locationText, builder: (column) => column);

  GeneratedColumn<int> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => column);

  GeneratedColumn<double> get budgetPkr =>
      $composableBuilder(column: $table.budgetPkr, builder: (column) => column);

  GeneratedColumn<String> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get upvotes =>
      $composableBuilder(column: $table.upvotes, builder: (column) => column);

  GeneratedColumn<int> get downvotes =>
      $composableBuilder(column: $table.downvotes, builder: (column) => column);

  GeneratedColumn<int> get viewCount =>
      $composableBuilder(column: $table.viewCount, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);
}

class $$LocalTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTasksTable,
    LocalTask,
    $$LocalTasksTableFilterComposer,
    $$LocalTasksTableOrderingComposer,
    $$LocalTasksTableAnnotationComposer,
    $$LocalTasksTableCreateCompanionBuilder,
    $$LocalTasksTableUpdateCompanionBuilder,
    (LocalTask, BaseReferences<_$AppDatabase, $LocalTasksTable, LocalTask>),
    LocalTask,
    PrefetchHooks Function()> {
  $$LocalTasksTableTableManager(_$AppDatabase db, $LocalTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> campaignId = const Value.absent(),
            Value<int?> beneficiaryId = const Value.absent(),
            Value<int?> createdBy = const Value.absent(),
            Value<int?> claimedBy = const Value.absent(),
            Value<int?> coordinatorId = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> familySize = const Value.absent(),
            Value<String> itemsNeeded = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> locationText = const Value.absent(),
            Value<int> radiusKm = const Value.absent(),
            Value<double> budgetPkr = const Value.absent(),
            Value<String> urgency = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> upvotes = const Value.absent(),
            Value<int> downvotes = const Value.absent(),
            Value<int> viewCount = const Value.absent(),
            Value<String?> createdAt = const Value.absent(),
            Value<String?> updatedAt = const Value.absent(),
            Value<String?> claimedAt = const Value.absent(),
          }) =>
              LocalTasksCompanion(
            id: id,
            campaignId: campaignId,
            beneficiaryId: beneficiaryId,
            createdBy: createdBy,
            claimedBy: claimedBy,
            coordinatorId: coordinatorId,
            sourceType: sourceType,
            title: title,
            description: description,
            category: category,
            familySize: familySize,
            itemsNeeded: itemsNeeded,
            latitude: latitude,
            longitude: longitude,
            locationText: locationText,
            radiusKm: radiusKm,
            budgetPkr: budgetPkr,
            urgency: urgency,
            status: status,
            upvotes: upvotes,
            downvotes: downvotes,
            viewCount: viewCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            claimedAt: claimedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> campaignId = const Value.absent(),
            Value<int?> beneficiaryId = const Value.absent(),
            Value<int?> createdBy = const Value.absent(),
            Value<int?> claimedBy = const Value.absent(),
            Value<int?> coordinatorId = const Value.absent(),
            required String sourceType,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> familySize = const Value.absent(),
            required String itemsNeeded,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> locationText = const Value.absent(),
            Value<int> radiusKm = const Value.absent(),
            Value<double> budgetPkr = const Value.absent(),
            required String urgency,
            required String status,
            Value<int> upvotes = const Value.absent(),
            Value<int> downvotes = const Value.absent(),
            Value<int> viewCount = const Value.absent(),
            Value<String?> createdAt = const Value.absent(),
            Value<String?> updatedAt = const Value.absent(),
            Value<String?> claimedAt = const Value.absent(),
          }) =>
              LocalTasksCompanion.insert(
            id: id,
            campaignId: campaignId,
            beneficiaryId: beneficiaryId,
            createdBy: createdBy,
            claimedBy: claimedBy,
            coordinatorId: coordinatorId,
            sourceType: sourceType,
            title: title,
            description: description,
            category: category,
            familySize: familySize,
            itemsNeeded: itemsNeeded,
            latitude: latitude,
            longitude: longitude,
            locationText: locationText,
            radiusKm: radiusKm,
            budgetPkr: budgetPkr,
            urgency: urgency,
            status: status,
            upvotes: upvotes,
            downvotes: downvotes,
            viewCount: viewCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            claimedAt: claimedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTasksTable,
    LocalTask,
    $$LocalTasksTableFilterComposer,
    $$LocalTasksTableOrderingComposer,
    $$LocalTasksTableAnnotationComposer,
    $$LocalTasksTableCreateCompanionBuilder,
    $$LocalTasksTableUpdateCompanionBuilder,
    (LocalTask, BaseReferences<_$AppDatabase, $LocalTasksTable, LocalTask>),
    LocalTask,
    PrefetchHooks Function()>;
typedef $$OutboxEntriesTableCreateCompanionBuilder = OutboxEntriesCompanion
    Function({
  Value<int> id,
  required String action,
  required String payload,
  Value<String> status,
  Value<DateTime> createdAt,
});
typedef $$OutboxEntriesTableUpdateCompanionBuilder = OutboxEntriesCompanion
    Function({
  Value<int> id,
  Value<String> action,
  Value<String> payload,
  Value<String> status,
  Value<DateTime> createdAt,
});

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxEntriesTable,
    OutboxEntry,
    $$OutboxEntriesTableFilterComposer,
    $$OutboxEntriesTableOrderingComposer,
    $$OutboxEntriesTableAnnotationComposer,
    $$OutboxEntriesTableCreateCompanionBuilder,
    $$OutboxEntriesTableUpdateCompanionBuilder,
    (
      OutboxEntry,
      BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>
    ),
    OutboxEntry,
    PrefetchHooks Function()> {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxEntriesCompanion(
            id: id,
            action: action,
            payload: payload,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String action,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxEntriesCompanion.insert(
            id: id,
            action: action,
            payload: payload,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxEntriesTable,
    OutboxEntry,
    $$OutboxEntriesTableFilterComposer,
    $$OutboxEntriesTableOrderingComposer,
    $$OutboxEntriesTableAnnotationComposer,
    $$OutboxEntriesTableCreateCompanionBuilder,
    $$OutboxEntriesTableUpdateCompanionBuilder,
    (
      OutboxEntry,
      BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>
    ),
    OutboxEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalTasksTableTableManager get localTasks =>
      $$LocalTasksTableTableManager(_db, _db.localTasks);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
}
