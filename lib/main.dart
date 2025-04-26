import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 9), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => FoodsShopMain()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation/Animation - 1742012004953.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Utils.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodsShopMain extends StatefulWidget {
  @override
  _FoodsShopMainState createState() => _FoodsShopMainState();
}

class _FoodsShopMainState extends State<FoodsShopMain> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  String selectedCategory = "All";
  List<Food> cart = [];
  List<Food> favorites = [];

  /// ✅ Fungsi untuk menambah/menghapus makanan dari daftar favorit
  void toggleFavorite(Food food) {
    setState(() {
      if (favorites.contains(food)) {
        favorites.remove(food);
      } else {
        favorites.add(food);
      }
    });
  }

  /// ✅ Fungsi untuk navigasi dengan animasi fade
  void _navigateToPage(int index) {
    if (index == _currentIndex) return;

    Widget page;
    if (index == 0) {
      page = FoodsShopMain();
    } else if (index == 1) {
      page = Page2(favorites: favorites, cart: cart);
    } else if (index == 2) {
      page = Page4(cart: cart, favorites: favorites);
    } else {
      page = Page5(cart: cart, favorites: favorites);
    }

    Navigator.of(context).pushReplacement(_createRoute(page));
    setState(() {
      _currentIndex = index;
    });
  }

  /// ✅ **Fungsi untuk transisi halaman yang lebih smooth dengan fade**
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FoodsPage> allPages = [
      FoodsPage(category: "Donuts", imgUrl: Utils.donutPromo1, logoImgUrl: Utils.donutLogoWhiteNoText),
      FoodsPage(category: "Donuts", imgUrl: Utils.donutPromo2, logoImgUrl: Utils.donutLogoWhiteNoText),
      FoodsPage(category: "Burgers", imgUrl: Utils.donutPromo3, logoImgUrl: Utils.donutLogoRedText),
    ];

    List<FoodsPage> pages = selectedCategory == "All"
        ? allPages
        : allPages.where((page) => page.category == selectedCategory).toList();

    return Scaffold(
      drawer: Drawer(child: DrawerSideMenu()),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Food Shop"),
      ),
      body: Column(
        children: [
          /// ✅ **Food Filter Bar**
          FoodFilterBar(
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),
          SizedBox(height: 10),

          /// ✅ **Food Pager**
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Image.network(
                          pages[index].imgUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Image.network(
                            pages[index].logoImgUrl!,
                            width: 100,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// **Page Indicator**
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.pink,
                dotColor: Colors.grey,
              ),
            ),
          ),

          /// ✅ **Food List Widget**
          Expanded(
            child: FoodListWidget(
              foods: Utils.foodList,
              cart: cart,
              favorites: favorites,
              onFavoriteToggle: toggleFavorite,
            ),
          ),
        ],
      ),

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Utils.mainColor,
        animationDuration: Duration(milliseconds: 300),
        index: _currentIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          _navigateToPage(index);
        },
      ),
    );
  }
}

class FoodsPager extends StatefulWidget {
  @override
  _FoodsPagerState createState() => _FoodsPagerState();
}

class _FoodsPagerState extends State<FoodsPager> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  String selectedCategory = "All"; // Default kategori yang dipilih

  List<FoodsPage> allPages = [
    FoodsPage(category: "Donuts", imgUrl: "assets/images/rot1.jpg", logoImgUrl: "assets/images/rot1.jpg"),
    FoodsPage(category: "Donuts", imgUrl: "assets/images/pizza2.jpg", logoImgUrl: "assets/images/rot1.jpg"),
    FoodsPage(category: "Burgers", imgUrl: "assets/images/roti4.jpg", logoImgUrl: "assets/images/rot1.jpg"),
  ];

  ScrollController _scrollController = ScrollController();
  bool _isFoodPagerVisible = true;
  bool _isFoodFilterVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _isFoodPagerVisible) {
        setState(() {
          _isFoodPagerVisible = false;
          _isFoodFilterVisible = false;
        });
      } else if (_scrollController.offset <= 50 && !_isFoodPagerVisible) {
        setState(() {
          _isFoodPagerVisible = true;
          _isFoodFilterVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FoodsPage> pages = selectedCategory == "All"
        ? allPages
        : allPages.where((page) => page.category == selectedCategory).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        AnimatedOpacity(
          opacity: _isFoodPagerVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: AnimatedPositioned(
            top: _isFoodPagerVisible ? 0 : -250,
            duration: Duration(milliseconds: 300),
            child: SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Image.asset(
                            pages[index].imgUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Image.asset(
                              pages[index].logoImgUrl!,
                              width: 100,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SmoothPageIndicator(
            controller: _pageController,
            count: pages.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Utils.mainColor,
              dotColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class FoodFilterBar extends StatefulWidget {
  final Function(String) onCategorySelected;

  const FoodFilterBar({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  _FoodFilterBarState createState() => _FoodFilterBarState();
}

class _FoodFilterBarState extends State<FoodFilterBar> {
  int selectedCategoryIndex = 0;

  final List<String> categories = [
    "All",
    "Donuts",
    "Burgers",
    "Pizzas",
    "Drinks",
    "Desserts",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
              widget.onCategorySelected(categories[index]);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Utils.mainColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodListWidget extends StatefulWidget {
  final List<Food> foods;
  final List<Food> cart;
  final List<Food> favorites; // List untuk menyimpan makanan favorit
  final Function(Food) onFavoriteToggle; // Callback untuk menangani favorite

  const FoodListWidget({
    Key? key,
    required this.foods,
    required this.cart,
    required this.favorites,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _FoodListWidgetState createState() => _FoodListWidgetState();
}

class _FoodListWidgetState extends State<FoodListWidget> {
  bool isViewAll = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header dengan tombol "View All"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quick & Easy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isViewAll = !isViewAll;
                  });
                },
                child: Text(
                  isViewAll ? "Close" : "View All",
                  style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        /// Tampilan list makanan
        Expanded(
          child: isViewAll
              ? GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 2,
            ),
            itemCount: widget.foods.length,
            itemBuilder: (context, index) {
              return buildFoodCard(widget.foods[index]);
            },
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.foods.map((food) {
                return Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: buildFoodCard(food, width: 200, height: 150),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget untuk menampilkan kartu makanan
  Widget buildFoodCard(Food food, {double width = double.infinity, double height = double.infinity}) {
    bool isFavorite = widget.favorites.contains(food);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailPage(
              food: food,
              cart: widget.cart,
              favorites: widget.favorites, // ✅ Tambahkan favorites
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            /// **Gunakan `Image.asset()` untuk menampilkan gambar dari assets**
            Image.asset(
              food.foodImage, // ✅ Menggunakan path assets
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),

            /// Overlay Gradient
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            /// Ikon Love (Favorite)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  widget.onFavoriteToggle(food);
                  setState(() {});
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                  size: 30,
                ),
              ),
            ),

            /// Nama Makanan & Detail
            Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.foodName,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    food.foodCategory,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Icon(Icons.fastfood, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text("${food.foodWeight}g", style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(width: 10),
                      Icon(Icons.storage, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text("Stock: ${food.foodQuantity}", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class FoodDetailPage extends StatefulWidget {
  final Food food;
  final List<Food> cart;
  final List<Food> favorites;

  const FoodDetailPage({Key? key, required this.food, required this.cart, required this.favorites}) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int quantity = 1;

  void addToCart() {
    setState(() {
      int index = widget.cart.indexWhere((item) => item.foodId == widget.food.foodId);
      if (index != -1) {
        widget.cart[index].quantity += quantity;
      } else {
        widget.cart.add(widget.food.copyWith(quantity: quantity));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.food.foodName} added to cart!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void toggleFavorite() {
    setState(() {
      if (widget.favorites.contains(widget.food)) {
        widget.favorites.remove(widget.food);
      } else {
        widget.favorites.add(widget.food);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.favorites.contains(widget.food) ? "Added to favorites!" : "Removed from favorites!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = widget.favorites.contains(widget.food);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ganti Image.network dengan Image.asset
            Image.asset(
              widget.food.foodImage, // Menggunakan gambar lokal
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.food.foodName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Category: ${widget.food.foodCategory}", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 10),
                  Text("Weight: ${widget.food.foodWeight}g", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 10),
                  Text(widget.food.foodDescription, style: TextStyle(color: Colors.black87)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            icon: Icon(Icons.remove_circle_outline),
                          ),
                          Text("$quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            icon: Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: Size(120, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class CartPage extends StatefulWidget {
  final List<Food> cart;
  final List<Food> favorites;

  const CartPage({Key? key, required this.cart, required this.favorites}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<int, bool> checkedItems = {}; // ✅ Status checkbox
  bool isSelectAll = false; // ✅ Status untuk "Pilih Semua"
  int _currentIndex = 2; // ✅ Indeks untuk halaman cart

  @override
  void initState() {
    super.initState();
    _resetCheckboxes();
  }

  /// ✅ Fungsi untuk reset semua checkbox (digunakan saat ada perubahan data)
  void _resetCheckboxes() {
    checkedItems = {for (int i = 0; i < widget.cart.length; i++) i: false};
    isSelectAll = false;
  }

  void _removeSelectedItems() {
    setState(() {
      widget.cart.removeWhere((food) => checkedItems[food.foodId] == true);
      _resetCheckboxes(); // Reset checkbox setelah penghapusan
    });
  }

  /// ✅ Fungsi untuk memilih/deselect semua item
  void _toggleSelectAll(bool? value) {
    setState(() {
      isSelectAll = value ?? false;
      checkedItems.updateAll((_, __) => isSelectAll);
    });
  }

  /// ✅ **Fungsi untuk navigasi dengan animasi smooth**
  void _navigateToPage(Widget page, int index) {
    if (_currentIndex == index) return; // Jika halaman sama, tidak perlu pindah

    Navigator.of(context).push(_createRoute(page));
    setState(() {
      _currentIndex = index;
    });
  }

  /// ✅ **Membuat efek transisi smooth**
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
        backgroundColor: Utils.mainColor,
        actions: [
          // ✅ Tombol hapus jika ada item yang dipilih
          if (checkedItems.containsValue(true))
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: _removeSelectedItems,
            ),
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(child: Text("Your cart is empty!"))
          : Column(
        children: [
          // ✅ Checkbox Pilih Semua
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: isSelectAll,
                  onChanged: _toggleSelectAll,
                ),
                Text("Select All"),
              ],
            ),
          ),

          // ✅ Daftar Item di Keranjang
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final food = widget.cart[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.asset(
                      food.foodImage.isNotEmpty ? food.foodImage : 'assets/image/placeholder.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/image/placeholder.png', width: 50, height: 50);
                      },
                    ),
                    title: Text(food.foodName),
                    subtitle: Text("Qty: ${food.quantity}"),
                    trailing: Checkbox(
                      value: checkedItems[index],
                      onChanged: (value) {
                        setState(() {
                          checkedItems[index] = value ?? false;
                          isSelectAll = checkedItems.values.every((v) => v);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),

      /// ✅ **Bottom Navigation Bar dengan navigasi smooth**
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Utils.mainColor,
        animationDuration: Duration(milliseconds: 300),
        index: _currentIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 0) {
            _navigateToPage(FoodsShopMain(), index);
          } else if (index == 1) {
            _navigateToPage(Page2(favorites: widget.favorites, cart: widget.cart), index);
          } else if (index == 3) {
            _navigateToPage(Page5(cart: widget.cart, favorites: widget.favorites), index);
          }
        },
      ),

    );
  }
}

class Page2 extends StatefulWidget {
  final List<Food> favorites;
  final List<Food> cart;

  const Page2({Key? key, required this.favorites, required this.cart}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  int _currentIndex = 1;
  bool _selectAll = false;
  List<Food> _selectedFavorites = [];

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;

    Widget page;
    if (index == 0) page = FoodsShopMain();
    else if (index == 2) page = Page4(cart: widget.cart, favorites: widget.favorites);
    else if (index == 3) page = Page5(cart: widget.cart, favorites: widget.favorites);
    else page = Page2(favorites: widget.favorites, cart: widget.cart);

    Navigator.pushReplacement(context, _createRoute(page));
    setState(() => _currentIndex = index);
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedFavorites = _selectAll ? List.from(widget.favorites) : [];
    });
  }

  void _toggleSelection(Food food) {
    setState(() {
      if (_selectedFavorites.contains(food)) {
        _selectedFavorites.remove(food);
      } else {
        _selectedFavorites.add(food);
      }
    });
  }

  void _removeSelectedFavorites() {
    if (_selectedFavorites.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to remove selected favorites?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.favorites.removeWhere((food) => _selectedFavorites.contains(food));
                _selectedFavorites.clear();
                _selectAll = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Selected favorites removed!")),
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Utils.mainColor,
        actions: [
          IconButton(
            icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: _toggleSelectAll,
          ),
          if (_selectedFavorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _removeSelectedFavorites,
            ),
        ],
      ),
      body: widget.favorites.isEmpty
          ? Center(child: Text("No favorites yet!"))
          : ListView.builder(
        itemCount: widget.favorites.length,
        itemBuilder: (context, index) {
          final food = widget.favorites[index];
          final isSelected = _selectedFavorites.contains(food);

          return GestureDetector(
            onTap: () => _toggleSelection(food),
            child: Card(
              color: isSelected ? Colors.grey[300] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Image.asset(
                  food.foodImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/image/placeholder.png', width: 50, height: 50);
                  },
                ),
                title: Text(food.foodName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(food.foodCategory),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeSelectedFavorites(),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Utils.mainColor,
        animationDuration: Duration(milliseconds: 300),
        index: _currentIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: _navigateToPage,
      ),
    );
  }
}

class Page4 extends StatefulWidget {
  final List<Food> cart;
  final List<Food> favorites;

  const Page4({Key? key, required this.cart, required this.favorites}) : super(key: key);

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  int _selectedIndex = 2;
  bool _selectAll = false;
  List<Food> _selectedItems = [];

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedItems = _selectAll ? List.from(widget.cart) : [];
    });
  }

  void _removeSelectedItems() {
    if (_selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to remove the selected items from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.cart.removeWhere((food) => _selectedItems.contains(food));
                _selectedItems.clear();
                _selectAll = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Selected items have been removed from the cart.")),
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(Widget page, int index) {
    if (index == _selectedIndex) return;

    Navigator.of(context).pushReplacement(_createRoute(page));
    setState(() {
      _selectedIndex = index;
    });
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        actions: [
          Checkbox(
            value: _selectAll,
            onChanged: (bool? value) => _toggleSelectAll(),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _removeSelectedItems,
          )
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(child: Text("Your cart is empty!"))
          : ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final food = widget.cart[index];
          final isSelected = _selectedItems.contains(food);

          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? _selectedItems.remove(food) : _selectedItems.add(food);
              });
            },
            child: Card(
              color: isSelected ? Colors.grey[300] : Colors.white,
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Image.asset(
                  food.foodImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/image/placeholder.png', width: 50, height: 50);
                  },
                ),
                title: Text(food.foodName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Qty: ${food.quantity}"),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      value == true ? _selectedItems.add(food) : _selectedItems.remove(food);
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Utils.mainColor,
        animationDuration: Duration(milliseconds: 300),
        index: _selectedIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 0) _navigateToPage(FoodsShopMain(), index);
          if (index == 1) _navigateToPage(Page2(favorites: widget.favorites, cart: widget.cart), index);
          if (index == 3) _navigateToPage(Page5(cart: widget.cart, favorites: widget.favorites), index);
        },
      ),
    );
  }
}

class Page5 extends StatefulWidget {
  final List<Food> cart;
  final List<Food> favorites;

  const Page5({Key? key, required this.cart, required this.favorites}) : super(key: key);

  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  int _currentIndex = 3; // ✅ Index untuk halaman Profile

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;

    Widget page;
    if (index == 0) page = FoodsShopMain();
    else if (index == 1) page = Page2(favorites: widget.favorites, cart: widget.cart);
    else if (index == 2) page = Page4(cart: widget.cart, favorites: widget.favorites);
    else page = Page5(cart: widget.cart, favorites: widget.favorites);

    Navigator.pushReplacement(context, _createRoute(page));
    setState(() => _currentIndex = index);
  }

  /// ✅ **Fungsi untuk transisi halaman yang smooth**
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Utils.mainColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            /// ✅ **Profile Avatar**
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile.jpg'), // Ganti dengan gambar profil
              ),
            ),
            SizedBox(height: 10),

            /// ✅ **Nama dan Email**
            Text("John Doe", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("johndoe@example.com", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),

            /// ✅ **Profile Menu**
            _buildProfileMenu(Icons.person, "Edit Profile"),
            _buildProfileMenu(Icons.settings, "Settings"),
            _buildProfileMenu(Icons.lock, "Change Password"),
            _buildProfileMenu(Icons.help, "Help & Support"),
            _buildProfileMenu(Icons.logout, "Logout", isLogout: true),
          ],
        ),
      ),

      /// ✅ **Bottom Navigation Bar yang sudah sesuai**
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Utils.mainColor,
        animationDuration: Duration(milliseconds: 300),
        index: _currentIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: _navigateToPage,
      ),
    );
  }

  /// ✅ **Widget untuk daftar menu profil**
  Widget _buildProfileMenu(IconData icon, String title, {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Utils.mainColor),
          title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (isLogout) {
              _showLogoutDialog();
            }
          },
        ),
      ),
    );
  }

  /// ✅ **Dialog konfirmasi logout**
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Tambahkan logika logout di sini
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class DrawerSideMenu extends StatefulWidget {
  @override
  _DrawerSideMenuState createState() => _DrawerSideMenuState();
}

class _DrawerSideMenuState extends State<DrawerSideMenu> {
  int _selectedIndex = 0; // Menyimpan indeks menu yang dipilih

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Tutup drawer setelah memilih menu
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Utils.mainColor),
              accountName: Text("Username"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage("https://via.placeholder.com/150"),
              ),
            ),
            _buildMenuItem(Icons.dashboard, "Dashboard", 0),
            _buildMenuItem(Icons.category, "Category", 1),
            _buildMenuItem(Icons.shopping_bag, "Products", 2),
            _buildMenuItem(Icons.settings, "Settings", 3),
            _buildMenuItem(Icons.logout, "Logout", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Utils.mainColor : Colors.black),
      title: Text(title, style: TextStyle(color: _selectedIndex == index ? Utils.mainColor : Colors.black)),
      tileColor: _selectedIndex == index ? Colors.pink.shade50 : Colors.transparent, // Warna latar belakang saat aktif
      onTap: () => _onItemTapped(index),
    );
  }
}

class Utils {
  static const Color mainColor = Color(0xFF57B4BA);
  static const Color mainDark = Color(0xFF007074);
  static const String donutLogoWhiteNoText = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_shop_logowhite_notext.png';
  static const String donutLogoWhiteText = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_shop_text_reversed.png';
  static const String donutLogoRedText = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_shop_text.png';
  static const String donutTitleFavorites = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_favorites_title.png';
  static const String donutTitleMyDonuts = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_mydonuts_title.png';
  static const String donutPromo1 = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_promo1.png';
  static const String donutPromo2 = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_promo2.png';
  static const String donutPromo3 = 'https://romanejaquez.github.io/flutter-codelab4/assets/donut_promo3.png';

  static const String foodPromo1 = 'https://example.com/roti_promo.jpg';
  static const String foodPromo2 = 'https://example.com/pizza_promo.jpg';
  static const String foodPromo3 = 'https://example.com/martabak_promo.jpg';
  static const String foodPromo4 = 'https://example.com/pisang_promo.jpg';
  static const String foodPromo5 = 'https://example.com/bakso_promo.jpg';

  static List<Food> foodList = [
    Food(
      foodId: 1,
      foodName: 'Roti Bakar',
      foodCategory: 'Roti',
      foodWeight: 150.0,
      foodType: 'Vegetarian',
      foodDescription: 'Roti panggang lezat dengan topping coklat dan keju.',
      foodImage: 'assets/image/roti1.png',
      foodQuantity: 20,
    ),
    Food(
      foodId: 2,
      foodName: 'Roti Gandum',
      foodCategory: 'Roti',
      foodWeight: 180.0,
      foodType: 'Vegetarian',
      foodDescription: 'Roti sehat dengan gandum utuh dan biji-bijian.',
      foodImage: 'assets/image/roti2.png',
      foodQuantity: 15,
    ),
    Food(
      foodId: 3,
      foodName: 'Roti Sobek',
      foodCategory: 'Roti',
      foodWeight: 200.0,
      foodType: 'Vegetarian',
      foodDescription: 'Roti sobek empuk dengan isian coklat lezat.',
      foodImage: 'assets/image/roti3.jpg',
      foodQuantity: 10,
    ),
    Food(
      foodId: 4,
      foodName: 'Roti Tawar',
      foodCategory: 'Roti',
      foodWeight: 250.0,
      foodType: 'Vegetarian',
      foodDescription: 'Roti tawar lembut yang cocok untuk sarapan.',
      foodImage: 'assets/image/roti4.png',
      foodQuantity: 12,
    ),
    Food(
      foodId: 5,
      foodName: 'Roti Manis',
      foodCategory: 'Roti',
      foodWeight: 220.0,
      foodType: 'Vegetarian',
      foodDescription: 'Roti manis dengan taburan gula dan mentega.',
      foodImage: 'assets/image/roti5.png',
      foodQuantity: 8,
    ),
    Food(
      foodId: 6,
      foodName: 'Pizza Pepperoni',
      foodCategory: 'Pizza',
      foodWeight: 400.0,
      foodType: 'Non-Vegetarian',
      foodDescription: 'Pizza dengan topping pepperoni dan keju mozzarella.',
      foodImage: 'assets/image/pizza1.png',
      foodQuantity: 9,
    ),
    Food(
      foodId: 7,
      foodName: 'Pizza Margarita',
      foodCategory: 'Pizza',
      foodWeight: 380.0,
      foodType: 'Vegetarian',
      foodDescription: 'Pizza klasik dengan tomat segar dan basil.',
      foodImage: 'assets/image/pizza2.png',
      foodQuantity: 10,
    ),
    Food(
      foodId: 8,
      foodName: 'Pizza BBQ Chicken',
      foodCategory: 'Pizza',
      foodWeight: 450.0,
      foodType: 'Non-Vegetarian',
      foodDescription: 'Pizza dengan topping ayam BBQ dan saus spesial.',
      foodImage: 'assets/image/pizza3.png',
      foodQuantity: 7,
    ),
    Food(
      foodId: 9,
      foodName: 'Pizza Vegetarian',
      foodCategory: 'Pizza',
      foodWeight: 390.0,
      foodType: 'Vegetarian',
      foodDescription: 'Pizza dengan topping sayuran segar dan keju.',
      foodImage: 'assets/image/pizza4.png',
      foodQuantity: 6,
    ),
    Food(
      foodId: 10,
      foodName: 'Pizza Tuna Mayo',
      foodCategory: 'Pizza',
      foodWeight: 370.0,
      foodType: 'Non-Vegetarian',
      foodDescription: 'Pizza dengan topping tuna dan mayones.',
      foodImage: 'assets/image/pizza5.png',
      foodQuantity: 5,
    ),
  ];

}

class Food {
  final int foodId;
  final String foodName;
  final String foodCategory;
  final double foodWeight;
  final String foodType;
  final String foodDescription;
  final String foodImage;
  final int foodQuantity;
  int quantity;

  Food({
    required this.foodId,
    required this.foodName,
    required this.foodCategory,
    required this.foodWeight,
    required this.foodType,
    required this.foodDescription,
    required this.foodImage,
    required this.foodQuantity,
     this.quantity = 1
  });
  Food copyWith({int? quantity}) {
    return Food(
      foodId: this.foodId,
      foodName: this.foodName,
      foodCategory: this.foodCategory,
      foodWeight: this.foodWeight,
      foodType: this.foodType,
      foodDescription: this.foodDescription,
      foodImage: this.foodImage,
      foodQuantity: this.foodQuantity,
      quantity: quantity ?? this.quantity,
    );
  }
}

class FoodsPage {
  String? category;
  String? imgUrl;
  String? logoImgUrl;

  FoodsPage({ this.category, this.imgUrl, this.logoImgUrl});
}


