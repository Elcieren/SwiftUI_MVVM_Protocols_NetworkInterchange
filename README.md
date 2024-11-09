## SwiftUI_MVVM_Protocols_NetworkInterchange
| Remote veri | Local veri |
|---------|---------|
| ![Video 1](https://github.com/user-attachments/assets/c9593863-4573-4e64-bd06-efb8213ab224) | ![Video 2](https://github.com/user-attachments/assets/c9eafca0-f5e4-4cce-a7e9-ed039ac0e883) |


 <details>
    <summary><h2>Uygulamanın Amacı ve Senaryo Mantığı</h2></summary>
    Proje Amacı
   Bu uygulama, iki farklı veri kaynağından (local JSON dosyası ve canlı web servisi) veri çekmek için yapılandırılmıştır. Amaç, arka uç (backend) tarafında yapılan değişiklikleri hızlıca test edebilmek ve veri akışını bir satırla değiştirebilmek. Geliştirilen senaryoya göre, arka uç geliştiren kişiyle iletişim kurarak, uygulama içinde yapılan JSON verisi değişikliklerini hızlıca görebilmek hedeflenmiştir. Bu nedenle, LocalService ve WebService sınıfları farklı veri çekme yöntemlerini implement eder, ancak ana yapı değişmeden kalır. Bu senaryoda, uygulama sadece hangi veri kaynağından veri çekeceğini belirler ve bu kaynak, kolayca değiştirilebilir.
  </details>  


  <details>
    <summary><h2>MVVM Yapısı</h2></summary>
     MVVM (Model-View-ViewModel) yapısı, uygulamanın veri ile ilgili iş mantığının View ve Model arasında temiz bir ayrım yaparak yönetilmesine olanak tanır. Bu yapı, uygulamanın daha kolay yönetilmesini, test edilmesini ve bakımının yapılmasını sağlar.
     - Model
     - View
     - Viewmodel
  </details> 

  <details>
    <summary><h2>Model</h2></summary>
    User, kullanıcıya ait tüm bilgileri içeren ana modeldir.
    Address, kullanıcı adresinin detaylarını tanımlar.
    Geo, adresin coğrafi koordinatlarını tutar.
    Company, kullanıcının çalıştığı şirket hakkında bilgiler içerir..
    
    ```
    struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
    }

    struct Address: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
    }

    struct Geo: Codable {
    let lat: String
    let lng: String
    }

    struct Company: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
    }
    ```
  </details> 


  <details>
    <summary><h2>View</h2></summary>
   MainView: Bu View, UserListViewModel'i gözlemler ve kullanıcı bilgilerini bir liste olarak gösterir.
   @ObservedObject: userListViewModel değiştiğinde UI'yi günceller.
    
    ```
    struct MainView: View {
    @ObservedObject var userListViewModel: UserListViewModel
    
    init() {
        self.userListViewModel = UserListViewModel(service: LocalService())
    }
    
    var body: some View {
        List(userListViewModel.userList, id: \.id) { user in
            VStack {
                Text(user.name).font(.title3).foregroundStyle(.blue).frame(maxWidth:.infinity , alignment: .leading)
                Text(user.username).font(.title3).foregroundStyle(.black).frame(maxWidth:.infinity , alignment: .leading)
                Text(user.email).font(.title3).foregroundStyle(.red).frame(maxWidth:.infinity , alignment: .leading)
            }
        }
        .task {
            await userListViewModel.downloadUsers()
        }
    }
    }

    #Preview {
    MainView()
    }
    ```
  </details> 


  <details>
    <summary><h2>ViewModel</h2></summary>
  UserListViewModel: Bu sınıf, NetworkService protokolüne uyan bir servis (hem local hem de web servisleri) kullanarak veriyi indirir. İndirilen kullanıcıları UserViewModel'a dönüştürür ve UI'ya sunar.
  UserViewModel: Bir kullanıcıyı temsil eder, ancak bu sınıf sadece UI için gerekli olan verilere sahiptir (ad, kullanıcı adı, e-posta gibi).
    
    ```
    class UserListViewModel: ObservableObject {
    @Published var userList = [UserViewModel]()
    
    private var service: NetworkService
    
    init(service: NetworkService) {
        self.service = service
    }
    
    func downloadUsers() async {
        var resource = ""
        
        if service.typ == "Webservice" {
            resource = Constants.Urls.userExtension
        } else {
            resource = Constants.Paths.baseUrl
        }
        
        do {
            let users = try await service.download(resource)
            DispatchQueue.main.async {
                self.userList = users.map(UserViewModel.init)
            }
        } catch {
            // Hata işleme
        }
    }
    }

    struct UserViewModel {
    let user: User
    
    var id: Int {
        user.id
    }
    
    var name: String {
        user.name
    }
    
    var username: String {
        user.username
    }
    
    var email: String {
        user.email
    }
    }


    ```
  </details> 

  

  
  <details>
    <summary><h2>NetworkService Protokolü</h2></summary>
   NetworkService protokolü, veri indirmek için gerekli olan metodu tanımlar. Hem LocalService hem de WebService, bu protokole uyarak kendi veri çekme yöntemlerini uygular.
    
    ```
    protocol NetworkService {
    func download(_ resource: String) async throws -> [User]
    var typ : String { get }
    }
    ```
  </details> 

  <details>
    <summary><h2>LocalService</h2></summary>
   typ: Bu özellik, sınıfın türünü belirtir. Burada "Localservice" olarak belirlenmiş, yani bu sınıf yerel veri kaynağından veri çekiyor.
   download fonksiyonu: Bu metod, parametre olarak bir resource (kaynak) alır. Bu kaynak, uygulama içindeki bir JSON dosyasının adı olmalıdır. Bundle.main.path(forResource:ofType:) fonksiyonu, uygulama içindeki JSON dosyasının tam yolunu bulur.
   JSON verisi, Data(contentsOf:) ile okunur.
   JSONDecoder().decode([User].self, from: data) ile JSON verisi, [User] türüne dönüştürülür.
   Eğer JSON dosyası bulunamazsa, fatalError("Resource not found") çağrılır ve uygulama çökertilir
    
    ```
    class LocalService: NetworkService {
    var typ: String = "Localservice"
    
    func download(_ resource: String) async throws -> [User] {
        // Uygulama içindeki JSON dosyasının yolunu alır
        guard let path = Bundle.main.path(forResource: resource, ofType: "json") else { 
            fatalError("Resource not found") 
        }
        
        // JSON dosyasını oku ve veri nesnesine çevir
        let data = try Data(contentsOf: URL(filePath: path))
        
        // JSON verisini [User] tipine dönüştür
        return try JSONDecoder().decode([User].self, from: data)
    }
    }




    ```
  </details> 

  <details>
    <summary><h2>WebService</h2></summary>
   typ: Bu özellik, sınıfın türünü belirtir. Burada "Webservice" olarak belirlenmiş, yani bu sınıf web servisinden veri çekiyor.
   download fonksiyonu: Bu metod, parametre olarak bir resource (kaynak) alır ve bunun bir URL olduğunu varsayar.
   URL Oluşturulması: URL(string: resource) ile URL oluşturulmaya çalışılır. Eğer geçersizse, NetworkError.invalidUrl hatası fırlatılır.
   Veri Çekme: URLSession.shared.data(from: url) ile web servisten veri çekilir.
   Yanıt Kontrolü: Yanıtın geçerli bir HTTP yanıtı olup olduğu kontrol edilir. Eğer yanıtın HTTP status code'u 200 (OK) değilse, NetworkError.invalidServerResponse hatası fırlatılır.
   Veri Dönüşümü: JSON verisi, JSONDecoder().decode([User].self, from: data) ile [User] türüne dönüştürülür.
    
    ```
    class WebService: NetworkService {
    var typ: String = "Webservice"
    
    func download(_ resource: String) async throws -> [User] {
        // URL'yi oluştur ve geçerli olup olmadığını kontrol et
        guard let url = URL(string: resource) else { throw NetworkError.invalidUrl }
        
        // Web servisten veri çek
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Geçerli bir HTTP yanıtı alındığından emin ol
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        // JSON verisini [User] tipine dönüştür
        return try JSONDecoder().decode([User].self, from: data)
    }
    }




    ```
  </details>

  <details>
    <summary><h2>NetworkError Enum</h2></summary>
   invalidUrl: Geçersiz bir URL adresi ile karşılaşıldığında kullanılır.
   invalidServerResponse: Sunucudan geçersiz veya hatalı bir yanıt alındığında bu hata kullanılır.
    
    ```
    enum NetworkError: Error {
    case invalidUrl
    case invalidServerResponse
    }


    ```
  </details>


<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Remote veri</h4>
            <img src="https://github.com/user-attachments/assets/b63044b7-9bd4-4c0a-a3d8-59a8d8ae9ede" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Local veri<</h4>
            <img src="https://github.com/user-attachments/assets/1e7c9de5-e45d-4d96-826e-d8d364f70609" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>
  </details> 
