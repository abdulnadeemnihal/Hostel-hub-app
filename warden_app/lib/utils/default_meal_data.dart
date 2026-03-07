/// Default 7-day meal menus for Vegetarian and Non-Vegetarian students.
/// Used to seed Firestore when no menus exist yet.

const List<Map<String, String>> defaultVegetarianMenu = [
  {
    'day': 'Monday',
    'breakfast': 'Idli, Sambar, Coconut Chutney',
    'lunch': 'Steamed Rice, Sambar, Cabbage Poriyal, Rasam, Curd',
    'snacks': 'Vegetable Upma, Tea',
    'dinner': 'Chapati, Chana Masala, Onion Salad',
  },
  {
    'day': 'Tuesday',
    'breakfast': 'Dosa, Sambar, Tomato Chutney',
    'lunch': 'Rice, Vegetable Kurma, Beans Poriyal, Rasam, Curd',
    'snacks': 'Masala Vada, Tea',
    'dinner': 'Vegetable Khichdi, Papad, Pickle',
  },
  {
    'day': 'Wednesday',
    'breakfast': 'Pongal, Sambar, Coconut Chutney',
    'lunch': 'Rice, Sambar, Carrot Beans Poriyal, Rasam, Buttermilk',
    'snacks': 'Samosa, Tea',
    'dinner': 'Chapati, Aloo Gobi',
  },
  {
    'day': 'Thursday',
    'breakfast': 'Poori, Potato Masala',
    'lunch': 'Rice, Kara Kuzhambu, Beetroot Poriyal, Rasam, Curd',
    'snacks': 'Paniyaram, Tea',
    'dinner': 'Vegetable Fried Rice, Gobi Manchurian',
  },
  {
    'day': 'Friday',
    'breakfast': 'Rava Upma, Coconut Chutney',
    'lunch': 'Rice, Vegetable Sambar, Potato Fry, Rasam, Curd',
    'snacks': 'Bonda, Tea',
    'dinner': 'Chapati, Paneer Butter Masala',
  },
  {
    'day': 'Saturday',
    'breakfast': 'Vegetable Semiya Upma, Chutney',
    'lunch': 'Vegetable Biryani, Raita',
    'snacks': 'Pakora, Tea',
    'dinner': 'Tomato Rice, Curd',
  },
  {
    'day': 'Sunday',
    'breakfast': 'Masala Dosa, Sambar, Coconut Chutney',
    'lunch': 'Rice, Sambar, Avial, Potato Roast, Rasam, Payasam',
    'snacks': 'Banana Bajji, Tea',
    'dinner': 'Chapati, Dal Tadka',
  },
];

const List<Map<String, String>> defaultNonVegetarianMenu = [
  {
    'day': 'Monday',
    'breakfast': 'Idli, Sambar, Coconut Chutney',
    'lunch': 'Rice, Sambar, Cabbage Poriyal, Rasam, Curd',
    'snacks': 'Samosa, Tea',
    'dinner': 'Chapati, Chana Masala',
  },
  {
    'day': 'Tuesday',
    'breakfast': 'Dosa, Sambar, Tomato Chutney',
    'lunch': 'Rice, Chicken Curry, Beans Poriyal, Rasam',
    'snacks': 'Samosa, Tea',
    'dinner': 'Chapati, Egg Masala',
  },
  {
    'day': 'Wednesday',
    'breakfast': 'Pongal, Sambar, Coconut Chutney',
    'lunch': 'Rice, Fish Curry, Carrot Beans Poriyal',
    'snacks': 'Samosa, Tea',
    'dinner': 'Chapati, Egg Curry',
  },
  {
    'day': 'Thursday',
    'breakfast': 'Poori, Potato Masala',
    'lunch': 'Rice, Kara Kuzhambu, Beetroot Poriyal',
    'snacks': 'Samosa, Tea',
    'dinner': 'Vegetable Fried Rice, Gobi Manchurian',
  },
  {
    'day': 'Friday',
    'breakfast': 'Rava Upma, Coconut Chutney',
    'lunch': 'Rice, Chicken Biryani, Raita',
    'snacks': 'Samosa, Tea',
    'dinner': 'Chapati, Chicken Masala',
  },
  {
    'day': 'Saturday',
    'breakfast': 'Vegetable Semiya Upma',
    'lunch': 'Rice, Egg Curry, Potato Fry',
    'snacks': 'Samosa, Tea',
    'dinner': 'Egg Fried Rice',
  },
  {
    'day': 'Sunday',
    'breakfast': 'Masala Dosa, Sambar, Coconut Chutney',
    'lunch': 'Rice, Sambar, Avial, Payasam',
    'snacks': 'Samosa, Tea',
    'dinner': 'Chapati, Dal Tadka',
  },
];
