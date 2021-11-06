//
//  ViewController.swift
//  CompositionalLayout-late2021
//
//  Created by Marcus Ziadé on 6.11.2021.
//

import UIKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        configureDataSource()
        applyInitialSnapshots()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMore))
    }
    
    // MARK: - Private
    
    private enum Section: Int, Hashable, CaseIterable {
        case main
        case secondary
        case grid
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        return view
    }()
    
    @objc private func addMore() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections(sections)
        
        var mainSnapshot = NSDiffableDataSourceSectionSnapshot<Int>()
        mainSnapshot.append(Array(1...4) + Array(3000...3005))
        dataSource.apply(mainSnapshot, to: .main)
    }
}

// MARK: - Data Source

extension ViewController {
    
    private func configureDataSource() {
        let listCellRegistration = listCell
        let secondaryRegistration = stackedCell
        let gridCellRegistration = gridCell
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, number in
            guard let sectionKind = Section(rawValue: indexPath.section) else { fatalError() }
            
            switch sectionKind {
            case .main:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: number)
            case .secondary:
                return collectionView.dequeueConfiguredReusableCell(using: secondaryRegistration, for: indexPath, item: number)
            case .grid:
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: number)
            }
        }
    }
    
    private func applyInitialSnapshots() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        var mainSnapshot = NSDiffableDataSourceSectionSnapshot<Int>()
        mainSnapshot.append(Array(1...4))
        
        var secondarySnapshot = NSDiffableDataSourceSectionSnapshot<Int>()
        secondarySnapshot.append(Array(2000...2020))
        
        var gridSnapshot = NSDiffableDataSourceSectionSnapshot<Int>()
        gridSnapshot.append(Array(5...12))
        
        dataSource.apply(mainSnapshot, to: .main, animatingDifferences: false)
        dataSource.apply(secondarySnapshot, to: .secondary, animatingDifferences: false)
        dataSource.apply(gridSnapshot, to: .grid, animatingDifferences: false)
    }
}

// MARK: - Layout

extension ViewController {
    
    private var layout: UICollectionViewLayout {
        let sectionProvider = {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let section: NSCollectionLayoutSection
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionKind {
            case .main:
                let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
                
            case .secondary:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.25),
                    heightDimension: .fractionalHeight(0.1)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                
            case .grid:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let leadingGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1.0)
                    ),
                    subitem: item,
                    count: 2
                )
                let trailingGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1.0)
                    ),
                    subitem: item,
                    count: 2
                )
                
                let nestedGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.5)
                    ),
                    subitems: [leadingGroup, trailingGroup]
                )
                
                section = NSCollectionLayoutSection(group: nestedGroup)
                section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
                section.interGroupSpacing = 24
            }
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

// MARK: - Cell configurations

extension ViewController {
    
    private var listCell: UICollectionView.CellRegistration<UICollectionViewListCell, Int> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Int> { cell , indexPath, number in
            var content = cell.defaultContentConfiguration()
            content.text = String(number)
            content.image = UIImage(systemName: "person.fill")
            content.imageProperties.tintColor = .systemPink
            content.secondaryText = "This is number: \(number)"
            
            cell.contentConfiguration = content
        }
    }
    
    private var stackedCell: UICollectionView.CellRegistration<MainCell, Int> {
        UICollectionView.CellRegistration<MainCell, Int> { cell, indexPath, number in
            cell.configure(with: number)
        }
    }
    
    private var gridCell: UICollectionView.CellRegistration<UICollectionViewCell, Int> {
        UICollectionView.CellRegistration<UICollectionViewCell, Int> { cell, indexPath, _ in
            cell.backgroundColor = .systemBlue
        }
    }
}
