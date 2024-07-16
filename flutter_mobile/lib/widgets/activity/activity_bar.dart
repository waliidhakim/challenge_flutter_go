
import 'package:flutter/material.dart';

enum ActivityBarType {
  small,
  extended,
}

class ActivityBar extends StatefulWidget {
  final ActivityBarType? type;

  const ActivityBar({super.key, this.type = ActivityBarType.small});

  @override
  State<ActivityBar> createState() => _ActivityBarState();
}

class _ActivityBarState extends State<ActivityBar> {
  bool _isExtended = false;
  bool _userIsParticipating = false;
  String _userVote = "";

  void _toggleExtended() {
    setState(() {
      _isExtended = !_isExtended;
    });
  }

  void handleVoteChange(value) {
    setState(() {
      _userVote = value;
    });
  }


  void selectAnotherDate(context) {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_isExtended)
        ? Container(
      child: Column(
        children: [
          Container(
            height: 125,
            decoration: BoxDecoration(
              border: Border.all(color: Theme
                  .of(context)
                  .colorScheme
                  .outline),
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
                      "Acroche",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
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
                          _userIsParticipating
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color:
                          _userIsParticipating ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _userIsParticipating = !_userIsParticipating;
                          });
                        }),
                    Text(
                      "4 personnes participent.",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Center(
                      child: IconButton(
                          onPressed: _toggleExtended,
                          icon: const Icon(Icons.expand_less_outlined)),
                    )
                  ],
                ),
              ],
            ),
          ),
          if (_userIsParticipating) Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme
                  .of(context)
                  .colorScheme
                  .outline),
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
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
                    ListTile(
                      title: Row(
                        children: [
                          const Text("Café Oz"),
                          const SizedBox(width: 8),
                          Text('(1 votes)', style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                      subtitle: const LinearProgressIndicator(
                        value: 0.3,
                      ),
                      leading: Radio(
                        value: "Café Oz",
                        groupValue: _userVote,
                        onChanged: (value) => {
                          if (value != null) {handleVoteChange(value)}
                        },
                      ),
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text('Le Phenix'),
                          const SizedBox(width: 8),
                          Text('(3 votes)', style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                      subtitle: const LinearProgressIndicator(
                        value: 0.7,
                      ),
                      leading: Radio(
                        value: "Le Phenix",
                        groupValue: _userVote,
                        onChanged: (value) => {
                          if (value != null) {handleVoteChange(value)}
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    )
        : Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme
            .of(context)
            .colorScheme.outline),
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
                "4 personnes participent.",
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall,
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
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
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
