//
//  StringExtensions.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation


extension String {
    
    var trimmed: String {
        get {
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
    }
    
    var isBlank: Bool {
        get {
            return trimmed.isEmpty
        }
    }
    
    var isEmail: Bool {
        get {
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let predicate = NSPredicate(format:"SELF MATCHES %@", pattern)
            return predicate.evaluateWithObject(trimmed.lowercaseString)
        }
    }
    
    var isPhoneNumber: Bool {
        get {
            let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
            var filtered:NSString!
            let inputString:NSArray = self.componentsSeparatedByCharactersInSet(charcter)
            filtered = inputString.componentsJoinedByString("")
            return  self == filtered
        }
    }
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    var onlyNumbers:String {
        get {
            return self.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil)
        }
    }
    
    var isCPFValid: Bool {
        get {
            let cpf = onlyNumbers
            
            if cpf == "00000000000" || cpf == "11111111111" || cpf == "22222222222" || cpf == "33333333333" || cpf == "44444444444" || cpf == "55555555555" || cpf == "66666666666" || cpf == "77777777777" || cpf == "88888888888" || cpf == "99999999999" || cpf.characters.count != 11 {
                return false
            }
            
            var soma = 0
            var peso: Int
            
            let digito_verificador_10 = Int(cpf[9])
            let digito_verificador_11 = Int(cpf[10])
            
            var digito_verificador_10_correto: Int
            var digito_verificador_11_correto: Int
            
            // Verificação 10 Digito
            peso = 10
            for i in 0 ..< 9 {
                soma = soma + (Int(cpf[i])! * peso)
                peso = peso - 1
            }
            
            if (soma % 11 < 2) {
                digito_verificador_10_correto = 0
            }else{
                digito_verificador_10_correto = 11 - (soma % 11)
            }
            
            // Verifição 11 Digito
            soma = 0
            peso = 11
            for i in 0 ..< 10 {
                soma = soma + (Int(cpf[i])! * peso)
                peso = peso - 1
            }
            
            if (soma % 11 < 2) {
                digito_verificador_11_correto = 0
            }
            else {
                digito_verificador_11_correto = 11 - (soma % 11)
            }
            
            if (digito_verificador_10_correto == digito_verificador_10 && digito_verificador_11_correto == digito_verificador_11) {
                return true
            }
            else {
                return false
            }
        }
    }
}