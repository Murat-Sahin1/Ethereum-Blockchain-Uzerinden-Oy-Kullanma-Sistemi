pragma solidity >=0.7.0 <0.9.0;

contract Secim{
    
    struct Aday{
        string isim;
        uint alinan_Oy;
    }
    
    struct Secmen{
        bool secime_yetkin; //Yalnızca yetkin olanların oy kullanabilmesini saglayacak olan degisken. Ornek: Yalnizca TC vatandaslari.
        bool oy_kullandi; //Secmenlerin birden fazla oy kullanamamasini saglayacak olan degisken.
    }
    
    address payable public kontrat_sahibi; // Kontratı block-chain'e yüklemek üzere kullanılacak olan adres değişkeni. Payable olmasının nedeni seçimin bitmesiyle kontratta kalan ETH'yi kontrat sahibi hesaba aktarmaktır.
    string public secim_adi; // Ne secimi oldugunu belirten degisken.
    
    mapping(address => Secmen) public Secmenler; // 'Key - Value' mantığı ile çalışan 'mapping' veri yapısı. Her seçmenin adresini tutan blok. Örnek: Her TC vatandaşı için bir adres 'key'i. Seçimden önce TC kimlik numaraları ile adresler oluşturulup dağıtılmalıdır.
    
    modifier yalnizca_kontrat_sahibi(){
        require (msg.sender == kontrat_sahibi); _;
        // Yalnızca kontrat sahibinin, ancak bir kez kullanabileceği fonksiyonelliği ekleyen yapı. Bu özelliği ekleyebilmek için diğer fonksyionlar tarafından inherit edilmesi gerekmektedir.
    }
    
    Aday[] public Adaylar; // Adaylari icerisinde tutan dizi.
    uint public toplam_kullanilan_oy; //Secimde atilan bütün oyların sayisi.
    
    constructor (string memory _secim_adi) {
        kontrat_sahibi = payable(msg.sender); // msg, fonksiyonu çağıran şahsı ifade eden objedir. Kontratı yükleyen şahsın adresini kontrat sahibi degiskenine atıyoruz. Not: Kontrat sahibi olmak, kontratı modere edebilme anlamına gelmemektedir. Kontrat sahibi, blockchaine kontratı yükleyecek olan şahıstır.
        secim_adi = _secim_adi; // Secimin adina degerini veriyoruz.
    }
    
    function aday_Ekle(string memory _isim) yalnizca_kontrat_sahibi public{ //Yalnızca kontrat sahibinin tek bir kez kullanabileceği secmen ekleme fonksiyonu. yalnizca_kontrat_sahibi inherit edildi, yani: fonksiyona girilmeden önce fonksiyonu çağıran şahısın kontrat sahibi olup olmadığı kontrol ediliyor.
        Adaylar.push(Aday(_isim, 0)); // Adaylar dizine yeni bir aday ekleniyor. İsim parametresi ve aldığı oy objeye aktarıldı.
    }
    
    function aday_sayisini_al() public view returns(uint){ //View modülü bu fonksiyonun hiçbir şey değiştirmeyeceğini belirtiyor. Returns(uint) ibaresiyle sadece bir sayı döndüreceğimizi belirtiyoruz.
        return Adaylar.length;
    }
    
    function yetkilendir(address _aday) yalnizca_kontrat_sahibi public{ // Oy kullanmak isteyen insanların TC vatandaşı olup olmadığını kontrol eden fonksiyon. Eğer öyleyse, oy kullanımına yetkin bir hale gelmektedirler.
        Secmenler[_aday].secime_yetkin = true; // Ek olarak, seçimden önce TC vatandaşları bu listeye eklenerek yetkilendirilmelidir.
    }
    
    function oy_kullanimi(uint _oyIndeksi) public { // Secmenlere oy kullandırtacak fonksiyon.
        require(!Secmenler[msg.sender].oy_kullandi);    // Oy kullanmak isteyen şahısın hali hazırda oy kullanıp kullanmadığını kontrol et.
        require(Secmenler[msg.sender].secime_yetkin); // Secmenin yetkilendirilip yetkilendirilmediğini kontrol et.
        
        Secmenler[msg.sender].oy_kullandi = true; // Seçmenin oy kullanmış olduğunu onayla, böylece bir daha oy kullanamasın.
        
        Adaylar[_oyIndeksi].alinan_Oy += 1; //Seçmenin oy kullandığı adayın oyunu bir arttır.
        toplam_kullanilan_oy += 1; // Toplam oy kullanma sayısını bir arttır.
    }
    
    function secimi_bitir () yalnizca_kontrat_sahibi public { // Yalnızca kontrat sahibinin kullanabileceği seçimi bitirme fonksiyonu.
        selfdestruct(kontrat_sahibi); // Kontratı imha eden fonksiyon. Bu fonksiyon çağırıldığı andan itibaren hiçbir fonksiyon kullanılamaz, veya hiçbir değişken değiştirilemez.
    }
}