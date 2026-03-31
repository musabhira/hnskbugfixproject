import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

import '/backend/supabase/supabase.dart';

import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';

/// SERIALIZATION HELPERS

String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  final startStr = dateTimeRange.start.millisecondsSinceEpoch.toString();
  final endStr = dateTimeRange.end.millisecondsSinceEpoch.toString();
  return '$startStr|$endStr';
}

String placeToString(FFPlace place) => jsonEncode({
      'latLng': place.latLng.serialize(),
      'name': place.name,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'country': place.country,
      'zipCode': place.zipCode,
    });

String uploadedFileToString(FFUploadedFile uploadedFile) =>
    uploadedFile.serialize();

String? serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final serializedValues = (param as Iterable)
          .map((p) => serializeParam(p, paramType, isList: false))
          .where((p) => p != null)
          .map((p) => p!)
          .toList();
      return json.encode(serializedValues);
    }
    String? data;
    switch (paramType) {
      case ParamType.int:
        data = param.toString();
      case ParamType.double:
        data = param.toString();
      case ParamType.String:
        data = param;
      case ParamType.bool:
        data = param ? 'true' : 'false';
      case ParamType.DateTime:
        data = (param as DateTime).millisecondsSinceEpoch.toString();
      case ParamType.DateTimeRange:
        data = dateTimeRangeToString(param as DateTimeRange);
      case ParamType.LatLng:
        data = (param as LatLng).serialize();
      case ParamType.Color:
        data = (param as Color).toCssString();
      case ParamType.FFPlace:
        data = placeToString(param as FFPlace);
      case ParamType.FFUploadedFile:
        data = uploadedFileToString(param as FFUploadedFile);
      case ParamType.JSON:
        data = json.encode(param);

      case ParamType.SupabaseRow:
        return json.encode((param as SupabaseDataRow).data);

      default:
        data = null;
    }
    return data;
  } catch (e) {
    print('Error serializing parameter: $e');
    return null;
  }
}

/// END SERIALIZATION HELPERS

/// DESERIALIZATION HELPERS

DateTimeRange? dateTimeRangeFromString(String dateTimeRangeStr) {
  final pieces = dateTimeRangeStr.split('|');
  if (pieces.length != 2) {
    return null;
  }
  return DateTimeRange(
    start: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.first)),
    end: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.last)),
  );
}

LatLng? latLngFromString(String? latLngStr) {
  final pieces = latLngStr?.split(',');
  if (pieces == null || pieces.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(pieces.first.trim()),
    double.parse(pieces.last.trim()),
  );
}

FFPlace placeFromString(String placeStr) {
  final serializedData = jsonDecode(placeStr) as Map<String, dynamic>;
  final data = {
    'latLng': serializedData.containsKey('latLng')
        ? latLngFromString(serializedData['latLng'] as String)
        : const LatLng(0.0, 0.0),
    'name': serializedData['name'] ?? '',
    'address': serializedData['address'] ?? '',
    'city': serializedData['city'] ?? '',
    'state': serializedData['state'] ?? '',
    'country': serializedData['country'] ?? '',
    'zipCode': serializedData['zipCode'] ?? '',
  };
  return FFPlace(
    latLng: data['latLng'] as LatLng,
    name: data['name'] as String,
    address: data['address'] as String,
    city: data['city'] as String,
    state: data['state'] as String,
    country: data['country'] as String,
    zipCode: data['zipCode'] as String,
  );
}

FFUploadedFile uploadedFileFromString(String uploadedFileStr) =>
    FFUploadedFile.deserialize(uploadedFileStr);

enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,

  SupabaseRow,
}

dynamic deserializeParam<T>(
  String? param,
  ParamType paramType,
  bool isList,
) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final paramValues = json.decode(param);
      if (paramValues is! Iterable || paramValues.isEmpty) {
        return null;
      }
      return paramValues
          .whereType<String>()
          .map((p) => p)
          .map((p) => deserializeParam<T>(p, paramType, false))
          .where((p) => p != null)
          .map((p) => p! as T)
          .toList();
    }
    switch (paramType) {
      case ParamType.int:
        return int.tryParse(param);
      case ParamType.double:
        return double.tryParse(param);
      case ParamType.String:
        return param;
      case ParamType.bool:
        return param == 'true';
      case ParamType.DateTime:
        final milliseconds = int.tryParse(param);
        return milliseconds != null
            ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
            : null;
      case ParamType.DateTimeRange:
        return dateTimeRangeFromString(param);
      case ParamType.LatLng:
        return latLngFromString(param);
      case ParamType.Color:
        return fromCssColor(param);
      case ParamType.FFPlace:
        return placeFromString(param);
      case ParamType.FFUploadedFile:
        return uploadedFileFromString(param);
      case ParamType.JSON:
        return json.decode(param);

      case ParamType.SupabaseRow:
        final data = json.decode(param) as Map<String, dynamic>;
        switch (T) {
          case ServiceRow:
            return ServiceRow(data);
          case BannersRow:
            return BannersRow(data);
          case BatchEnrollmentsRow:
            return BatchEnrollmentsRow(data);
          case CoursesEnrollmentsRow:
            return CoursesEnrollmentsRow(data);
          case GroupsRow:
            return GroupsRow(data);
          case LikespostsRow:
            return LikespostsRow(data);
          case ProfileFollowCountsRow:
            return ProfileFollowCountsRow(data);
          case BatchesRow:
            return BatchesRow(data);
          case AllCoursessRow:
            return AllCoursessRow(data);
          case TotalSharesRow:
            return TotalSharesRow(data);
          case HomeRow:
            return HomeRow(data);
          case DemoRow:
            return DemoRow(data);
          case ThreadsRow:
            return ThreadsRow(data);
          case ProfileGalleryServiceLikesCommentsViewRow:
            return ProfileGalleryServiceLikesCommentsViewRow(data);
          case CommentRepliesRow:
            return CommentRepliesRow(data);
          case AllcoursesRow:
            return AllcoursesRow(data);
          case StatusLikesRow:
            return StatusLikesRow(data);
          case ThreadCommentsRow:
            return ThreadCommentsRow(data);
          case CourseFavoritesViewRow:
            return CourseFavoritesViewRow(data);
          case HideRow:
            return HideRow(data);
          case RewardedAdClicksRow:
            return RewardedAdClicksRow(data);
          case BlocksRow:
            return BlocksRow(data);
          case ProfileGalleryServiceLikesViewRow:
            return ProfileGalleryServiceLikesViewRow(data);
          case GroupMessagesRow:
            return GroupMessagesRow(data);
          case StoriesRow:
            return StoriesRow(data);
          case EphemeralMessagesRow:
            return EphemeralMessagesRow(data);
          case LikepostRow:
            return LikepostRow(data);
          case GalleryRow:
            return GalleryRow(data);
          case MessageNotificationsRow:
            return MessageNotificationsRow(data);
          case ReportsRow:
            return ReportsRow(data);
          case PromptsRow:
            return PromptsRow(data);
          case CoursesTechRow:
            return CoursesTechRow(data);
          case ThreadLikesRow:
            return ThreadLikesRow(data);
          case ReelWatchRecordsRow:
            return ReelWatchRecordsRow(data);
          case AppCodesRow:
            return AppCodesRow(data);
          case AllcoursesTechRow:
            return AllcoursesTechRow(data);
          case UserCouponsRow:
            return UserCouponsRow(data);
          case LessonsRow:
            return LessonsRow(data);
          case HideCertsRow:
            return HideCertsRow(data);
          case VideosRow:
            return VideosRow(data);
          case FriendNotesRow:
            return FriendNotesRow(data);
          case PostsRow:
            return PostsRow(data);
          case FriendlistRow:
            return FriendlistRow(data);
          case EventParticipantsRow:
            return EventParticipantsRow(data);
          case FollowsRow:
            return FollowsRow(data);
          case ProductsRow:
            return ProductsRow(data);
          case AutoLoginRow:
            return AutoLoginRow(data);
          case CommentLikesRow:
            return CommentLikesRow(data);
          case StatusViewsRow:
            return StatusViewsRow(data);
          case WatchSessionsRow:
            return WatchSessionsRow(data);
          case CommentRepliesWithProfilesRow:
            return CommentRepliesWithProfilesRow(data);
          case CommunitiesRow:
            return CommunitiesRow(data);
          case UserCourseAccessRow:
            return UserCourseAccessRow(data);
          case AnnouncementsRow:
            return AnnouncementsRow(data);
          case GroupActivitiesRow:
            return GroupActivitiesRow(data);
          case ThreadCommentsViewRow:
            return ThreadCommentsViewRow(data);
          case PremiumFeaturesRow:
            return PremiumFeaturesRow(data);
          case PremiumbannergalleryRow:
            return PremiumbannergalleryRow(data);
          case MaterialsRow:
            return MaterialsRow(data);
          case ProfileRow:
            return ProfileRow(data);
          case SharesRow:
            return SharesRow(data);
          case MessagesRow:
            return MessagesRow(data);
          case GalleryWithCommentsViewRow:
            return GalleryWithCommentsViewRow(data);
          case NotesRow:
            return NotesRow(data);
          case ThreadsViewRow:
            return ThreadsViewRow(data);
          case DailyEarningsRow:
            return DailyEarningsRow(data);
          case EventsRow:
            return EventsRow(data);
          case CommentsRow:
            return CommentsRow(data);
          case BatchCodesRow:
            return BatchCodesRow(data);
          case GamesRow:
            return GamesRow(data);
          case UserProgressRow:
            return UserProgressRow(data);
          case StatusesRow:
            return StatusesRow(data);
          case AppUpdatesRow:
            return AppUpdatesRow(data);
          case AdWatchLimitsRow:
            return AdWatchLimitsRow(data);
          case FavoriteCoursesRow:
            return FavoriteCoursesRow(data);
          case UsersRow:
            return UsersRow(data);
          case StocksRow:
            return StocksRow(data);
          case CustomizedProductsRow:
            return CustomizedProductsRow(data);
          case LikesRow:
            return LikesRow(data);
          case GroupMembersRow:
            return GroupMembersRow(data);
          case LessonsTechRow:
            return LessonsTechRow(data);
          case TrendingRow:
            return TrendingRow(data);
          case ConversationsRow:
            return ConversationsRow(data);
          case OfflineEventRow:
            return OfflineEventRow(data);
          case CoursesRow:
            return CoursesRow(data);
          default:
            return null;
        }

      default:
        return null;
    }
  } catch (e) {
    print('Error deserializing parameter: $e');
    return null;
  }
}
