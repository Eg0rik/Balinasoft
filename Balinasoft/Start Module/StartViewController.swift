//
//  ViewController.swift
//  Balinasoft
//
//  Created by MAC on 11/5/24.
//

import UIKit

import UIKit
import Alamofire
import Combine

class StartViewController: UIViewController {
    
    //MARK: - Private properties
    private let viewModel: StartViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    private var lastCellUsedInSections = Set<Int>()
    private let tableInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var selectedRowId: Int?
    private var selectedImage: UIImage?
    
    private lazy var photoPicker: PhotoPicker = {
        let picker = PhotoCameraPicker()
        picker.delegate = self
        return picker
    }()
    
    //MARK: - Views
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .init(), style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        return table
    }()
    
    //MARK: - Life Cycle
    init(viewModel: StartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        subscribeToViewModelPubslishers()
        setupConstraints()
    }
}

//MARK: - Private methods
private extension StartViewController {
    func setupView() {
        view.addSubview(tableView)
        view.backgroundColor = .white
    }
    
    func subscribeToViewModelPubslishers() {
        subscribeToPagesForTableViewDataSource()
        subscribeToAlertMessage()
    }
    
    func subscribeToPagesForTableViewDataSource() {
        viewModel.$pages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pages in
                self?.addSection(index: pages.count - 1)
            }
            .store(in: &subscriptions)
    }
    
    func subscribeToAlertMessage() {
        viewModel.$alertMessage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alertContent in
                self?.showAlertController(alertContent: alertContent)
            }
            .store(in: &subscriptions)
    }
    
    func addSection(index: Int) {
        guard index >= 0 else { return }
        
        let indexSet = IndexSet(integer: index)
        
        tableView.performBatchUpdates({
            tableView.insertSections(indexSet, with: .automatic)
        })
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: tableInsets.left),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -tableInsets.right),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: tableInsets.top),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -tableInsets.bottom),
        ])
    }
    
    func showAlertController(alertContent: AlertContent) {
        let alert = UIAlertController(title: alertContent.title, message: alertContent.message, preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension StartViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.pages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pages[section].content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let section = indexPath.section
        
        let cell: PagesCell
        
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: PagesCell.identifier) as? PagesCell {
            cell = reuseCell
        } else {
            cell = PagesCell(style: .default, reuseIdentifier: PagesCell.identifier)
        }
        
        let rowContent = viewModel.pages[section].content[row]
        cell.configure(rowContent: rowContent, imageLoader: viewModel)
        
        //After showing the last cell in section, load the next page.
        //The last cell of each section must be used to load next page exactly once.
        if row + 1 == viewModel.pages[section].pageSize && !lastCellUsedInSections.contains(section) {
            viewModel.loadNextPage()
            
            lastCellUsedInSections.insert(section)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Page \(section)"
    }
}

//MARK: - UITableViewDelegate
extension StartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowId = viewModel.pages[indexPath.section].content[indexPath.row].id
        
        photoPicker.present()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - PhotoPickerDelegate
extension StartViewController: PhotoPickerDelegate {
    func picker(_ picker: any PhotoPicker, didSelect image: UIImage) {
        viewModel.uploadImage(image: image, id: selectedRowId ?? -1, name: "Egor")
    }
}

#Preview {
    StartViewController(viewModel: StartViewModel())
}
