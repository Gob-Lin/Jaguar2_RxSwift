//
//  MainViewModel.swift
//  Jaguar2
//
//  Created by Paolo Piccini on 25/03/23.
//

import AEXML
import Foundation
import RxSwift

typealias Contents = [ContentModel]

class MainViewModel {
  let extContentsSubject = BehaviorSubject<Contents>(value: [])
  let urlRequestSubject = PublishSubject<URLRequest?>()
  let pdfRequestSubject = PublishSubject<URLRequest?>()
  var currentDocumentToQL: ContentModel?
  let bag = DisposeBag()

  init() {
    loadExternalContents("contents")
  }

  private func parseXML(_ myXML: Data) {
    var extContents: Contents = []

    do {
      let xmlDoc = try AEXMLDocument(xml: myXML)

      if let contents = xmlDoc.root["content"].all {
        extContents = contents.compactMap { aexmlElement in
          guard
            let id = aexmlElement.attributes["id"],
            let icon = aexmlElement.attributes["icon"],
            let type = aexmlElement.attributes["type"]
          else {
            return nil
          }

          return ContentModel(
            id: id,
            icon: icon,
            type: type
          )
        }
      }
      self.extContentsSubject.onNext(extContents)
    } catch {
      print("\(error)")
    }
  }
}

extension MainViewModel {
  public func loadExternalContents(_ refXMLName: String) {
    if let path: String = Bundle.main.path(
      forResource: "archivio/data/\(refXMLName)",
      ofType: "xml"
    ) {
      do {
        let text = try String(contentsOfFile: path)
        let data: Data = (text as NSString).data(using: String.Encoding.utf8.rawValue) ?? Data()
        parseXML(data)
      } catch {
        print(error)
      }
    }
  }

  public func loadEDetail() {
    let path = URL(fileURLWithPath: Bundle.main.bundlePath)
    let baseURL = path.appendingPathComponent("archivio/index.html")
    urlRequestSubject.onNext(URLRequest(url: baseURL))
  }
}
