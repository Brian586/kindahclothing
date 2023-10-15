sortDates(dynamic a, dynamic b) {
  final dateA = a.date!;
  final dateB = b.date!;

  final dayA = int.parse(dateA.split(' ')[0]);
  final monthA = monthMap[dateA.split(' ')[1]];

  final dayB = int.parse(dateB.split(' ')[0]);
  final monthB = monthMap[dateB.split(' ')[1]];

  // Comparing the months first
  if (monthA != monthB) {
    return monthA!.compareTo(monthB!);
  }

  // If the months are the same, compare the days
  return dayA.compareTo(dayB);
}

// Define a map to convert month names to their corresponding numerical values
Map<String, int> monthMap = {
  'Jan': 1,
  'Feb': 2,
  'Mar': 3,
  'Apr': 4,
  'May': 5,
  'Jun': 6,
  'Jul': 7,
  'Aug': 8,
  'Sep': 9,
  'Oct': 10,
  'Nov': 11,
  'Dec': 12,
};
