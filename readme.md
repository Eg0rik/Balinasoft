### Отчет:
- Главный экран реализован с помощью архитектуры `MVVM` и `Combine` без Storyboard-ов
- Сетевой слой `NetworkService.swift` для запросов использует библиотеку `Alamofire`
- `Alamofire` поставил с помощью CocoaPods
- Для создания последовательных запросов использовал serial очередь `DispatchQueue`
- Для возможности сделать фотографию использовал `UIImagePickerController` 
- Подгрузка след страницы в `UITableView` осуществляется только после показа последней ячейки последней отображенной страницы.
- Загруженные картинки записываются в `NSCache`