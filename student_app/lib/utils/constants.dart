class AppConstants {
  static const String appName = 'Hostel Student';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String studentsCollection = 'students';
  static const String complaintsCollection = 'complaints';
  static const String leaveCollection = 'leave_applications';
  static const String roomsCollection = 'rooms';
  static const String feesCollection = 'fees';
  static const String mealsCollection = 'meal_menus';
  static const String mealPreferencesCollection = 'meal_preferences';
  static const String mealPollsCollection = 'meal_polls';
  static const String announcementsCollection = 'announcements';
  static const String attendanceCollection = 'attendance';
  static const String gatePassCollection = 'gate_passes';
  static const String wardensCollection = 'wardens';

  // Complaint Categories & Sub-categories
  static const List<String> complaintCategories = [
    'Maintenance',
    'AC',
    'Carpentry',
    'Electrical',
    'Plumbing',
  ];

  static const Map<String, List<String>> complaintSubCategories = {
    'Maintenance': ['Room Cleaning', 'RestRoom Cleaning', 'Civil Works'],
    'AC': ['Leakage Problem', 'Slow Cooling', 'Remote', 'Not Working'],
    'Carpentry': [
      'CupBoard',
      'Door',
      'CupBoard Mirror',
      'Bathroom Mirror',
      'Mosquito Mesh',
      'Cot',
      'Chair',
      'Study Table',
      'Book Shelf',
      'Door Frame',
      'Bathroom Hanger',
      'Towel Stand',
      'Soap Stand',
      'Curtain',
      'Table',
      'Others',
    ],
    'Electrical': [
      'Tubelight',
      'Fans',
      'Study Table Light',
      'Switches',
      'Sockets',
      'Others',
    ],
    'Plumbing': [
      'FlushTank',
      'Faucet',
      'Wash Basin',
      'Tap',
      'Shower',
      'Water Blockages',
      'Others',
    ],
  };

  // Complaint Urgency Levels
  static const List<String> urgencyLevels = ['Basic', 'Medium', 'Critical'];

  // Complaint Status
  static const List<String> complaintStatuses = [
    'Pending',
    'Processing',
    'Fixed',
  ];

  // Leave Types
  static const List<String> leaveTypes = [
    'Home',
    'Medical',
    'Personal',
    'Emergency',
    'Academic',
  ];

  // Leave Reasons (predefined categories)
  static const List<String> leaveReasons = [
    'Medical Issues',
    'Internship',
    'Purchase',
    'Outing',
    'Semester Vacation',
    'Visiting Home',
    'Others',
  ];

  // Modes of Transportation
  static const List<String> modesOfTransport = [
    'Bus',
    'Train',
    'Auto',
    'Cab/Taxi',
    'Own Vehicle',
    'By Walk',
    'Flight',
    'Other',
  ];

  // Room Types
  static const List<String> roomTypes = ['Single', 'Double', 'Triple'];

  // Hostel Blocks
  static const List<String> hostelBlocks = [
    'Block A',
    'Block B',
    'Block C',
    'Block D',
  ];

  // Departments
  static const List<String> departments = [
    'Computer Science',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electronics',
    'Information Technology',
    'Chemical Engineering',
    'Biotechnology',
  ];

  // Branches
  static const List<String> branches = [
    'CSE',
    'CSE (AI & ML)',
    'CSE (Data Science)',
    'CSE (Cyber Security)',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'CHEM',
    'BIO',
  ];

  // Years
  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  // Gender
  static const List<String> genders = ['Male', 'Female'];

  // Food Preference
  static const List<String> foodPreferences = ['Vegetarian', 'Non-Vegetarian'];

  // Room Sharing Preference
  static const List<String> roomPreferences = ['Single', 'Double', 'Triple'];

  // Referral code to prevent outsiders
  static const String validReferralCode = 'NOTHING';

  // Languages
  static const List<String> languages = [
    'English',
    'Tamil',
    'Telugu',
    'Hindi',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Bengali',
    'Gujarati',
    'Punjabi',
    'Urdu',
    'Odia',
  ];

  // Days of week
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
