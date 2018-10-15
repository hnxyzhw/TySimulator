//
//  AppMenuViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2018/10/15.
//  Copyright © 2018 luckytianyiyan. All rights reserved.
//

import Foundation

class AppMenuViewController: NSViewController {
    @IBOutlet weak var deviceTableView: NSTableView!
    @IBOutlet weak var infoCollectionView: NSCollectionView!
    
    @IBOutlet weak var progressView: NSProgressIndicator!
    var devices: [DeviceModel] = []
    var recentItems: [NSMenuItem] = []
    var selectedDeviceUDID: String?
    
    var selectedDevice: DeviceModel? {
        guard let udid = selectedDeviceUDID else {
            return nil
        }
        return devices.first(where: { $0.udid == udid })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.selectionHighlightStyle = .none
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        infoCollectionView.register(NSNib(nibNamed: "AppMenuViewController", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultItem"))
        infoCollectionView.delegate = self
        infoCollectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicesChangedNotification(sender:)), name: Notification.Name.Device.DidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recentAppsDidRecordNotification), name: Notification.Name.LRUCache.DidRecord, object: nil)
        
        devices = Simulator.shared.devices
        infoCollectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        progressView.startAnimation(nil)
        DispatchQueue.global().async {
            Simulator.shared.updateDeivces()
            DispatchQueue.main.async {
                self.progressView.stopAnimation(nil)
            }
        }
    }
    
    private func updateDeviceMenus() {
        log.verbose("update devices")
        
        devices = Simulator.shared.devices
        log.info("load devices: \(devices.count)")
        
        deviceTableView.reloadData()
    }
    
    private func updateRecentAppMenus() {
//        guard let menu = statusItem.menu else {
//            return
//        }
//        menu.removeItems(recentItems)
//        recentItems.removeAll()
//        let datas = LRUCache.shared.datas
//        guard datas.count > 0 else {
//            return
//        }
//        var apps: [ApplicationModel] = []
//        let bootedDevices = Simulator.shared.bootedDevices
//        for bundleID in datas {
//            for device in bootedDevices {
//                if let app = device.application(bundleIdentifier: bundleID) {
//                    apps.append(app)
//                    break
//                }
//            }
//        }
//
//        guard apps.count > 0 else {
//            return
//        }
//
//        log.verbose("update recent apps")
//        let titleItem = NSMenuItem.sectionMenuItem(NSLocalizedString("menu.recent", comment: "menu"))
//
//        var models: [ApplicationModel] = []
//        for (idx, app) in apps.enumerated() {
//            if idx > 2 {
//                break
//            }
//            models.append(app)
//        }
//
//        let appItems = NSMenuItem.applicationMenuItems(models, style: .detail)
//        for menuItem in appItems.reversed() {
//            menu.insertItem(menuItem, at: 0)
//        }
//        menu.insertItem(titleItem, at: 0)
//        recentItems = [titleItem] + appItems
    }
    
    // MARK: Notification
    @objc func devicesChangedNotification(sender: Notification) {
        log.verbose("devicesChangedNotification updateDeviceMenus")
        self.updateDeviceMenus()
    }
    
    @objc func recentAppsDidRecordNotification() {
        updateRecentAppMenus()
    }
}

extension AppMenuViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: AppMenuTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! AppMenuTableCellView
        if devices.indices.contains(row) {
            let device = devices[row]
            result.name = device.name
            result.isAvailable = device.isOpen
            result.isHighlight = device.udid == selectedDeviceUDID
        }
        return result
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if devices.indices.contains(deviceTableView.selectedRow) {
            selectedDeviceUDID = devices[deviceTableView.selectedRow].udid
        }
        deviceTableView.deselectAll(nil)
        deviceTableView.reloadData()
        infoCollectionView.reloadData()
    }
}

extension AppMenuViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }
}

extension AppMenuViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedDevice?.applications.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultItem"), for: indexPath) as! ApplicationCollectionItem
        if let applications = selectedDevice?.applications, applications.indices.contains(indexPath.item) {
            let app = applications[indexPath.item]
            item.icon = app.bundle.appIcon
            item.name = app.bundle.appName
        }
        return item
    }
}

extension AppMenuViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return CGSize(width: collectionView.bounds.width, height: 49)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        if let applications = selectedDevice?.applications, applications.indices.contains(indexPath.item) {
            let app = applications[indexPath.item]
            LRUCache.shared.record(app: app.bundle.bundleID)
            NSWorkspace.shared.open(app.dataPath)
        }
    }
}

class AppMenuTableCellView: NSTableCellView {
    var name: String? {
        set {
            textField?.stringValue = newValue ?? ""
        }
        get {
            return textField?.stringValue
        }
    }
    var isAvailable: Bool = false {
        didSet {
            imageView?.image = isAvailable ? NSImage(named: "icon-on") : NSImage(named: "icon-off")
        }
    }
    
    var isHighlight: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isAvailable = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isHighlight {
            NSColor.selectedMenuItemColor.set()
            dirtyRect.fill()
        }
    }
}

class ApplicationCollectionItem: NSCollectionViewItem {
    var icon: NSImage? {
        set {
            newValue?.isTemplate = false
            imageView?.image = newValue ?? NSImage(named: "tmp-logo")
        }
        get {
            return imageView?.image
        }
    }
    var name: String? {
        set {
            textField?.stringValue = newValue ?? ""
        }
        get {
            return textField?.stringValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.wantsLayer = true
        imageView?.layer?.cornerRadius = 4.0
        imageView?.layer?.masksToBounds = true
    }
}
