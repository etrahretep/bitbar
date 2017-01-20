import AppKit
import EmitterKit

class ItemBase: NSMenuItem {
  let clickEvent = Event<ItemBase>()
  var listeners = [Listener]() {
    didSet { activate() }
  }

  init(_ title: String, key: String = "", block: @escaping Block<ItemBase>) {
    super.init(title: title, action: #selector(didClick), keyEquivalent: key)
    target = self
    listeners.append(clickEvent.on(block))
    activate()
    attributedTitle = NSMutableAttributedString(withDefaultFont: title)
  }

  convenience init(_ title: String, key: String = "", voidBlock: @escaping Block<Void>) {
    self.init(title, key: key) { (_: ItemBase) in voidBlock() }
  }

  /**
    @title A title to be displayed
    @key A keyboard shortcut to simulate @self being clicked
  */
  init(_ title: String, key: String = "") {
    super.init(title: title, action: nil, keyEquivalent: key)
    if key.isEmpty { deactivate() }
    else { activate() }
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /**
    Add @menu as a submenu to @self
  */
  func addSub(_ menu: NSMenuItem) {
    if submenu == nil { submenu = NSMenu() }
    submenu?.addItem(menu)
    activate()
  }

  /**
    Add menu as submenu to @self

    @title A title to be displayed
    if @check, then prefix @title with a checkbox
    @key An optional shortcut, i.e "x" which can be invoked with cmd+x
    @block to be called when title is clicked or invoked with @key
  */
  func addSub(_ name: String, checked: Bool = false, key: String = "", block: @escaping Block<Void>) {
    addSub(name, checked: checked, key: key) { (_:ItemBase) in block() }
  }

  /**
    Same as above, but passes the invoked item as an argument to @block
  */
  func addSub(_ name: String, checked: Bool = false, key: String = "", b: @escaping Block<ItemBase>) {
    let menu = ItemBase(name, key: key, block: b)
    addSub(menu)
    menu.state = checked ? NSOnState : NSOffState
  }

  /**
    Call @block when item is clicked
  */
  func onDidClick(block: @escaping () -> Void) {
    listeners.append(clickEvent.on { _ in block() })
  }

  /**
    Append a separator to the submenu
  */
  func separator() {
    addSub(NSMenuItem.separator())
  }

  // Private
  @objc func didClick(_ sender: NSMenu) {
    clickEvent.emit(self)
  }

  private func activate() {
    isEnabled = true
  }

  private func deactivate() {
    isEnabled = false
  }
}