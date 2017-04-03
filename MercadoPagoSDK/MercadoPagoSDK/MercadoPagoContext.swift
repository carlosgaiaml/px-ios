//
//  MercadoPagoContext.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit


open class MercadoPagoContext : NSObject, MPTrackerDelegate {
    
    static let sharedInstance = MercadoPagoContext()
    
    var trackListener : MPTrackListener?
    
    var public_key: String = ""
    
    var payer_access_token: String = ""
    
    var merchant_access_token: String = ""
    
    var initialFlavor: Flavor?
    
    var payment_key : String = ""
    
    var site : Site!
    
    var termsAndConditionsSite : String!

    var account_money_available = false
    
    var currency : Currency!
    
    var display_default_loading = true
    

    var language: String = NSLocale.preferredLanguages[0]
    
    open class var PUBLIC_KEY : String {
        return "public_key"
    }
    
    open class var PRIVATE_KEY : String {
        return "access_token"
    }

    open class func isAuthenticatedUser() -> Bool{
        return !sharedInstance.payer_access_token.isEmpty
    }

    public func flavor() -> Flavor!{
        if (initialFlavor == nil){
        return Flavor.Flavor_3
    }else{
                return initialFlavor
        }
    
    }
    
    open func framework() -> String!{
        return  "iOS"
    }
    open func sdkVersion() -> String!{
        return "3.0.0-BETA-7"
    }
 
    static let siteIdsSettings : [String : NSDictionary] = [
        //Argentina
        "MLA" : ["language" : "es", "currency" : "ARS","termsconditions" : "https://www.mercadopago.com.ar/ayuda/terminos-y-condiciones_299", "showPayerCostDescription" : true],
        //Brasil
        "MLB" : ["language" : "pt", "currency" : "BRL","termsconditions" : "https://www.mercadopago.com.br/ajuda/termos-e-condicoes_300", "showPayerCostDescription" : true],
        //Chile

        "MLC" : ["language" : "es", "currency" : "CLP","termsconditions" : "https://www.mercadopago.cl/ayuda/terminos-y-condiciones_299", "showPayerCostDescription" : true],
        //Mexico
        "MLM" : ["language" : "es-MX", "currency" : "MXN","termsconditions" : "https://www.mercadopago.com.mx/ayuda/terminos-y-condiciones_715", "showPayerCostDescription" : true],
        //Peru
        "MPE" : ["language" : "es", "currency" : "PEN","termsconditions" : "https://www.mercadopago.com.pe/ayuda/terminos-condiciones-uso_2483", "showPayerCostDescription" : true],
        //Uruguay
        "MLU" : ["language" : "es", "currency" : "UYU","termsconditions" : "https://www.mercadopago.com.uy/ayuda/terminos-y-condiciones-uy_2834", "showPayerCostDescription" : true],
        //Colombia
        "MCO" : ["language" : "es-CO", "currency" : "COP","termsconditions" : "https://www.mercadopago.com.co/ayuda/terminos-y-condiciones_299", "showPayerCostDescription" : false],
        //Venezuela
        "MLV" : ["language" : "es", "currency" : "VEF","termsconditions" : "https://www.mercadopago.com.ve/ayuda/terminos-y-condiciones_299", "showPayerCostDescription" : true]
]


    public enum Site : String {
        case MLA = "MLA"
        case MLB = "MLB"
        case MLM = "MLM"
        case MLV = "MLV"
        case MLU = "MLU"
        case MPE = "MPE"
        case MLC = "MLC"
        case MCO = "MCO"
    }
    

    
    @objc public enum Languages : Int {
        case _SPANISH
        case _SPANISH_MEXICO
        case _SPANISH_COLOMBIA
        case _SPANISH_URUGUAY
        case _SPANISH_PERU
        case _SPANISH_VENEZUELA
//        case _SPANISH_CHILE

        case _PORTUGUESE
        case _ENGLISH
        
        func langPrefix() -> String {
            switch self {
            case ._SPANISH : return "es"
            case ._SPANISH_MEXICO : return "es-MX"
            case ._SPANISH_COLOMBIA : return "es-CO"
            case ._SPANISH_URUGUAY : return "es-UY"
            case ._SPANISH_PERU : return "es-PE"
            case ._SPANISH_VENEZUELA : return "es-VE"
//            case ._SPANISH_CHILE : return "es-CH"
                
            case ._PORTUGUESE : return "pt"
            case ._ENGLISH : return "en"
            }
        }
        
        
    }
    
    open func siteId() -> String! {
        return site.rawValue
    }
    
    fileprivate func setSite(_ site : Site) {
        let siteConfig = MercadoPagoContext.siteIdsSettings[site.rawValue]
        if siteConfig != nil {
            self.site = site
            self.termsAndConditionsSite = siteConfig!["termsconditions"] as! String
            let currency = CurrenciesUtil.getCurrencyFor(siteConfig!["currency"] as? String)
            if currency != nil {
                self.currency = currency!
            }
        }
    }

    open class func setSite(_ site : Site) {
        MercadoPagoContext.sharedInstance.setSite(site)
    }
    
    open class func getSite() -> String{
        return MercadoPagoContext.sharedInstance.site.rawValue
    }
    
    open class func showPayerCostDescriptionForSite() -> Bool{
        let site = MercadoPagoContext.getSite()
        let siteConfig = MercadoPagoContext.siteIdsSettings[site]
        let flag = siteConfig!["showPayerCostDescription"] as! Bool
        return flag
    }
    
    open class func setSiteID(_ siteId : String) {
        let site = Site(rawValue: siteId)
        if site != nil {
            MercadoPagoContext.setSite(site!)
        }
    }
    
    open class func setTrack(listener : MPTrackListener) {
        MercadoPagoContext.sharedInstance.trackListener = listener
    }
    
    open static func getTrackListener() -> MPTrackListener? {
        return sharedInstance.trackListener
    }
    open static func setLanguage(language: Languages) -> Void {
        sharedInstance.language = language.langPrefix()
    }
    open static func getLanguage() -> String {
        return sharedInstance.language
    }
    open static func getLocalizedPath() -> String {
        let bundle = MercadoPago.getBundle() ?? Bundle.main
        
        let currentLanguage = MercadoPagoContext.getLanguage()
        if let path = bundle.path(forResource: currentLanguage, ofType : "lproj"){
            return path
        } else if let path = bundle.path(forResource: MercadoPagoContext.getLanguage().components(separatedBy: "-")[0], ofType : "lproj"){
            return path
        } else {
            let path = bundle.path(forResource: "es", ofType : "lproj")
            return path!
        }
    }
    
    open static func getTermsAndConditionsSite() -> String {
        return sharedInstance.termsAndConditionsSite
    }
    
    open static func getCurrency() -> Currency {
        return sharedInstance.currency
    }

    open func publicKey() -> String!{
        return self.public_key
    }
    
    fileprivate override init() {
        super.init()
        MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
        self.setSite(Site.MLA)
    }
    
    open class func setPayerAccessToken(_ payerAccessToken : String){
        
        
        sharedInstance.payer_access_token = payerAccessToken.trimSpaces()
      _ = CardFrontView()
      _ = CardBackView()
        
    }
    
    open class func setPublicKey(_ public_key : String){
        
       sharedInstance.public_key = public_key.trimSpaces()
       _ = CardFrontView()
       _ = CardBackView()
        
    }
    
    public class func initFlavor1(){
        if (MercadoPagoContext.sharedInstance.initialFlavor != nil){
            return
        }
        MercadoPagoContext.sharedInstance.initialFlavor = Flavor.Flavor_1
    }
    
    public class func initFlavor2(){
        if (MercadoPagoContext.sharedInstance.initialFlavor != nil){
            return
        }
        MercadoPagoContext.sharedInstance.initialFlavor = Flavor.Flavor_2
    }
    
    public class func initFlavor3(){
        if (MercadoPagoContext.sharedInstance.initialFlavor != nil){
            return
        }
        MercadoPagoContext.sharedInstance.initialFlavor = Flavor.Flavor_3
    }
    
    open class func setAccountMoneyAvailable(accountMoneyAvailable : Bool) {
        sharedInstance.account_money_available = accountMoneyAvailable
    }
    
    open class func setDisplayDefaultLoading(flag : Bool){
        sharedInstance.display_default_loading = flag
    }
    
    open class func merchantAccessToken() -> String {
        return sharedInstance.merchant_access_token
    }
    
    open class func publicKey() -> String {
        return sharedInstance.public_key
    }
    
    open class func payerAccessToken() -> String {
        return sharedInstance.payer_access_token
    }
    
    open class func accountMoneyAvailable() -> Bool {
        return sharedInstance.account_money_available
    }
    
    open class func shouldDisplayDefaultLoading() -> Bool {
        return sharedInstance.display_default_loading
    }
    
    open class func paymentKey() -> String {
        if sharedInstance.payment_key == "" {
            sharedInstance.payment_key = String(arc4random()) + String(Date().timeIntervalSince1970)
        }
        return sharedInstance.payment_key
    }
    
    open class func clearPaymentKey(){
        sharedInstance.payment_key = ""
    }
    
    open class func keyType() -> String{
        if(MercadoPagoContext.isAuthenticatedUser()){
            return MercadoPagoContext.PRIVATE_KEY
        }else{
            return MercadoPagoContext.PUBLIC_KEY
        }
    }
    
    open class func keyValue() -> String{
        if(MercadoPagoContext.isAuthenticatedUser()){
            return MercadoPagoContext.payerAccessToken()
        }else{
            return MercadoPagoContext.publicKey()
        }
    }
    
}


