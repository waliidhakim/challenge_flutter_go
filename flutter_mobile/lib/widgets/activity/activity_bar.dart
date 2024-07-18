import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/activity.dart';
import 'package:flutter_mobile/models/group_chat.dart';
import 'package:flutter_mobile/models/location.dart';
import 'package:flutter_mobile/models/location_vote.dart';
import 'package:flutter_mobile/services/activity_service.dart';
import 'package:flutter_mobile/services/location_service.dart';
import 'package:flutter_mobile/services/location_vote_service.dart';
import 'package:flutter_mobile/services/websocket_service.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';

enum ActivityBarType {
  small,
  extended,
}

class ActivityBar extends StatefulWidget {
  final ActivityBarType? type;
  final String groupId;
  final GroupChat groupChatInfo;
  final WebSocketService websocketService;
  final int nbParticipants;
  final ValueNotifier<List<LocationVote>>? wsGroupVotes;

  // final Future<List<LocationVote>> groupVotes;

  const ActivityBar({
    super.key,
    this.type = ActivityBarType.small,
    required this.groupId,
    required this.websocketService,
    required this.nbParticipants,
    required this.groupChatInfo,
    required this.wsGroupVotes,
    // required this.groupVotes,
  });

  @override
  State<ActivityBar> createState() => _ActivityBarState();
}

class _ActivityBarState extends State<ActivityBar> {
  bool _isExtended = false;
  bool _userIsParticipating = false;
  int? _userVote;
  final String userId = sharedPrefs.userId;
  late Future<Activity> userActivity;
  late Future<List<Location>> groupLocations;
  late Future<List<LocationVote>> groupVotes;

  void _toggleExtended() {
    setState(() {
      _isExtended = !_isExtended;
    });
  }

  void handleParticipationChange() {
    if (_userIsParticipating) {
      userActivity.then((value) {
        if (value.id != null && value.id != 0) {
          ActivityService().deleteGroupChatActivity(value.id!);
          LocationVoteService().deleteVoteInGroup(int.parse(widget.groupId)).then((value) {
            widget.websocketService.groupVotes();
          });
          setState(() {
            _userIsParticipating = false;
            _userVote = 0;
          });
          widget.websocketService.groupParticipants(widget.nbParticipants - 1);
        }
      });
    } else {
      // create user activity
      ActivityService().createGroupChatActivity(int.parse(widget.groupId), DateTime.now()).then((value) {
        setState(() {
          _userIsParticipating = true;
          userActivity = Future.value(value);
        });
        widget.websocketService.groupParticipants(widget.nbParticipants + 1);
      });
    }
  }

  void handleVoteChange(value) {
    LocationVoteService().deleteVoteInGroup(int.parse(widget.groupId));
    LocationVoteService().createVote(value, int.parse(widget.groupId)).then((value) {
      widget.websocketService.groupVotes();
    });
    setState(() {
      _userVote = value;
    });
  }

  Future<void> selectAnotherDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ActivityService().createGroupChatActivity(
        int.parse(widget.groupId),
        DateTime(picked.year, picked.month, picked.day, 12),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userActivity = ActivityService().fetchUserGroupChatActivity(widget.groupId);
    // set state with the fetched settings
    userActivity.then((value) {
      if (value.id != 0) {
        setState(() {
          _userIsParticipating = true;
        });
      }
    });
    groupLocations = LocationService().fetchGroupLocations(int.parse(widget.groupId));
    groupVotes = LocationVoteService().fetchGroupLocationVotes(int.parse(widget.groupId));
    groupVotes.then((votes) {
      if (votes.where((vote) {
        return vote.userId == int.parse(userId);
      }).isNotEmpty) {
        var userVote = votes.firstWhere((vote) => vote.userId == int.parse(userId));
        setState(() {
          _userVote = userVote.locationId;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return (_isExtended)
        ? Container(
            child: Column(
              children: [
                Container(
                  height: 125,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.groupChatInfo.catchPhrase,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                              onPressed: () {
                                selectAnotherDate(context);
                              },
                              icon: const Icon(Icons.calendar_month)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionChip(
                              label: Text("Je participe"),
                              avatar: Icon(
                                _userIsParticipating ? Icons.check_circle : Icons.check_circle_outline,
                                color: _userIsParticipating ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                handleParticipationChange();
                              }),
                          Text(
                            "${widget.nbParticipants} personnes participent.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Center(
                            child: IconButton(onPressed: _toggleExtended, icon: const Icon(Icons.expand_less_outlined)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if (_userIsParticipating)
                  FutureBuilder<List<Location>>(
                      future: groupLocations,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Error loading locations");
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Lieux",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                      onPressed: () {
                                        selectAnotherDate(context);
                                      },
                                      icon: const Icon(Icons.directions)),
                                ],
                              ),
                              Column(
                                children: [
                                  for (Location location in snapshot.data!)
                                    FutureBuilder(
                                        future: groupVotes,
                                        builder: (context, votes) {
                                          if (votes.connectionState == ConnectionState.waiting) {
                                            return const Text("Loading votes...");
                                          }
                                          if (votes.hasError) {
                                            return const Text("Error loading votes");
                                          }

                                          return ListTile(
                                            title: Row(
                                              children: [
                                                Text(location.name!),
                                                const SizedBox(width: 8),
                                                Builder(builder: (context) {
                                                  var wsLength = widget.wsGroupVotes!.value.where((vote) => vote.locationId == location.id).length;
                                                  var dbLength =  votes.data!.isNotEmpty ? votes.data!.where((vote) => vote.locationId == location.id).length : 0;
                                                  return Text('(${widget.wsGroupVotes!.value.isEmpty ? dbLength : wsLength} votes)',
                                                      style: Theme.of(context).textTheme.bodySmall);
                                                })
                                              ],
                                            ),
                                            subtitle: Builder(builder: (context) {
                                              var wsLength = widget.wsGroupVotes!.value.where((vote) => vote.locationId == location.id).length;
                                              var wsTotal = widget.wsGroupVotes!.value.length;
                                              var dbLength = votes.data!.isNotEmpty ? votes.data!.where((vote) => vote.locationId == location.id).length : 0;
                                              var dbTotal = votes.data!.isNotEmpty ? votes.data!.length : 0;
                                              var progress = widget.wsGroupVotes!.value.isEmpty ? dbLength / dbTotal : wsLength / wsTotal;

                                              return LinearProgressIndicator(
                                                value: progress.isNaN ? 0 : progress,
                                              );
                                            }),
                                            leading: Radio(
                                              value: location.id!,
                                              groupValue: _userVote,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  handleVoteChange(value);
                                                }
                                              },
                                            ),
                                          );
                                        }),
                                ],
                              )
                            ],
                          ),
                        );
                      }),
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${widget.nbParticipants} personnes participent.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    // display icon if _userIsParticipating is true
                    if (_userIsParticipating)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Text(
                      "Le Phenix",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    IconButton(
                      onPressed: _toggleExtended,
                      icon: const Icon(Icons.expand_more),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
