/*
 * Procédures stockées suivant le principe CRUD
 * pour la persistance des objets
 */
USE cliiink;

# Suppression des éventuelles procédures exitantes
DROP PROCEDURE IF EXISTS PI_Categorie; 
DROP PROCEDURE IF EXISTS PI_CategorieSimple; 
DROP PROCEDURE IF EXISTS PSGetCategorie; 
DROP PROCEDURE IF EXISTS PL_Categorie;
DROP PROCEDURE IF EXISTS PU_Categorie; 
DROP PROCEDURE IF EXISTS PD_Categorie; 
DROP PROCEDURE IF EXISTS PD_CategorieCascade; 
DROP PROCEDURE IF EXISTS PD_CategorieByType; 
DROP PROCEDURE IF EXISTS PD_CategorieByTypeCascade; 
DROP PROCEDURE IF EXISTS PIU_Categorie; 
DROP PROCEDURE IF EXISTS PI_Dechet; 
DROP PROCEDURE IF EXISTS PI_DechetSimple; 
DROP PROCEDURE IF EXISTS PSGetDechet; 
DROP PROCEDURE IF EXISTS PL_Dechet;
DROP PROCEDURE IF EXISTS PU_Dechet; 
DROP PROCEDURE IF EXISTS PD_Dechet; 
DROP PROCEDURE IF EXISTS PD_DechetCascade; 
DROP PROCEDURE IF EXISTS PD_DechetByType; 
DROP PROCEDURE IF EXISTS PD_DechetByTypeCascade; 
DROP PROCEDURE IF EXISTS PIU_Dechet; 
DROP PROCEDURE IF EXISTS PI_Decheterie;
DROP PROCEDURE IF EXISTS PI_DecheterieSimple;
DROP PROCEDURE IF EXISTS PI_DecheterieMin;
DROP PROCEDURE IF EXISTS PSGetDecheterie;
DROP PROCEDURE IF EXISTS PL_Decheterie;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateInstallation;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateInstallationInterval;
DROP PROCEDURE IF EXISTS PL_DecheterieByAdresse;
DROP PROCEDURE IF EXISTS PL_DecheterieByCodeInsee;
DROP PROCEDURE IF EXISTS PL_DecheterieByCreateur;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateCreation;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateCreationInterval;
DROP PROCEDURE IF EXISTS PL_DecheterieByModificateur;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateModification;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateModificationInterval;
DROP PROCEDURE IF EXISTS PL_DecheterieByGlobalid;
DROP PROCEDURE IF EXISTS PL_DecheterieByCoordonnees;

DROP PROCEDURE IF EXISTS PD_Decheterie;
DROP PROCEDURE IF EXISTS PD_DecheterieCascade;


DROP PROCEDURE IF EXISTS PI_Marque; 
DROP PROCEDURE IF EXISTS PI_MarqueSimple; 
DROP PROCEDURE IF EXISTS PSGetMarque; 
DROP PROCEDURE IF EXISTS PL_Marque;
DROP PROCEDURE IF EXISTS PU_Marque; 
DROP PROCEDURE IF EXISTS PD_Marque; 
DROP PROCEDURE IF EXISTS PD_MarqueCascade; 
DROP PROCEDURE IF EXISTS PD_MarqueByNom; 
DROP PROCEDURE IF EXISTS PD_MarqueByNomCascade; 
DROP PROCEDURE IF EXISTS PIU_Marque; 

DROP PROCEDURE IF EXISTS PI_Traitement;
DROP PROCEDURE IF EXISTS PL_Traitement;
DROP PROCEDURE IF EXISTS PL_TraitementByObjectidDecheterie;
DROP PROCEDURE IF EXISTS PL_TraitementByIdDecheterie;
DROP PROCEDURE IF EXISTS PD_Traitement;
DROP PROCEDURE IF EXISTS PI_Tri; 
DROP PROCEDURE IF EXISTS PI_TriSimple; 
DROP PROCEDURE IF EXISTS PSGetTri; 
DROP PROCEDURE IF EXISTS PL_Tri;
DROP PROCEDURE IF EXISTS PU_Tri; 
DROP PROCEDURE IF EXISTS PD_Tri; 
DROP PROCEDURE IF EXISTS PD_TriCascade; 
DROP PROCEDURE IF EXISTS PD_TriByType; 
DROP PROCEDURE IF EXISTS PD_TriByTypeCascade; 
DROP PROCEDURE IF EXISTS PIU_Tri; 

# On change le délimiteur de la fin d'une instruction (; remplacé par $$)
# pour que MySQL lise chaque procédure d'un bloc
DELIMITER $$

/* 
CRUD TABLE categorie
*/

-- CREATE 

# Ajoute une catégorie avec un identifiant et un type 
CREATE PROCEDURE PI_Categorie(IN idCategorie SMALLINT, IN typeCategorie VARCHAR(30))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le type existe déjà
		IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce type existe déjà";
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO categorie VALUES(idCategorie, typeCategorie);
		END IF;
    # Fin du 1er IF    
	END IF$$

# Ajoute une catégorie avec juste son type (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_CategorieSimple(IN typeCategorie VARCHAR(30))
	# On vérifie que le type n'existe pas déjà
    IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le type existe déjà";
	ELSE
		INSERT INTO categorie(type) VALUES(typeCategorie);
	END IF$$

-- RETRIEVE

# Affiche la catégorie d'identifiant idCategorie
CREATE PROCEDURE PSGetCategorie(IN idCategorie SMALLINT)
	SELECT id, type FROM categorie 
    WHERE id = idCategorie$$

# Affiche toutes les catégories
CREATE PROCEDURE PL_Categorie()
	SELECT id, type FROM categorie$$

-- UPDATE

# Change le type de la catégorie d'identifiant idCategorie
CREATE PROCEDURE PU_Categorie(IN idCategorie SMALLINT, IN typeCategorie VARCHAR(30))
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    # Alors
	THEN 
		# On vérifie que le type n'existe pas déjà
		IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE categorie
				SET type = typeCategorie
			# de la catégorie d'identifiant idCategorie         
			WHERE id = idCategorie;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime la catégorie d'identifiant idCategorie
CREATE PROCEDURE PD_Categorie(IN idCategorie SMALLINT)
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    THEN
		# Si l'identifiant de la catégorie est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idCategorie (colonne dans collecteur) = idCategorie (entrée de la procédure)
		IF EXISTS(SELECT * FROM collecteur WHERE idCategorie = idCategorie)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La catégorie a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM categorie WHERE id = idCategorie;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
    
  # Supprime la catégorie d'identifiant idCategorie et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_CategorieCascade(IN idCategorie SMALLINT)
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    THEN
		# Réinitialisation à NULL des références à cette catégorie dans collecteur
		UPDATE collecteur 
			SET idCategorie = NULL
        WHERE idCategorie = idCategorie;
        # Suppresion de la catégorie
		DELETE FROM categorie WHERE id = idCategorie;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la catégorie selon le type
CREATE PROCEDURE PD_CategorieByType(IN typeCategorie VARCHAR(30))
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
    THEN
		# Si l'identifiant associé au type de la catégorie est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idCategorie (colonne dans collecteur) = id associé au type de la catégorie
		IF EXISTS(SELECT * FROM collecteur WHERE idCategorie = (SELECT id FROM categorie WHERE type = typeCategorie))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La catégorie a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM categorie WHERE type = typeCategorie;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la catégorie selon le type et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_CategorieByTypeCascade(IN typeCategorie VARCHAR(30))
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
    THEN
		# Réinitialisation à NULL des références à cette catégorie dans collecteur
		UPDATE collecteur 
			SET idCategorie = NULL
		WHERE idCategorie = (SELECT id FROM categorie WHERE type = typeCategorie);
        # Suppresion de la catégorie
        DELETE FROM categorie WHERE type = typeCategorie;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
	
-- BONUS

# Ajoute une catégorie si elle n'existe pas, la met à jour sinon
CREATE PROCEDURE PIU_Categorie(IN idCategorie SMALLINT, IN typeCategorie VARCHAR(30))
	# Si le type existe déjà
	IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce type existe déjà";
	ELSE
		# Si la catégorie existe déjà
		IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
		THEN 	
			# On la met à jour
			UPDATE categorie
				SET type = typeCategorie WHERE id = idCategorie;
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO categorie VALUES(idCategorie, typeCategorie);
		END IF;
	END IF$$

/* 
CRUD TABLE dechet
*/

-- CREATE 

# Ajoute un déchet avec un identifiant et un type 
CREATE PROCEDURE PI_Dechet(IN idDechet SMALLINT, IN typeDechet VARCHAR(30))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le type existe déjà
		IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce type existe déjà";
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO dechet VALUES(idDechet, typeDechet);
		END IF;
    # Fin du 1er IF    
	END IF$$

# Ajoute un déchet avec juste son type (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_DechetSimple(IN typeDechet VARCHAR(30))
	# On vérifie que le type n'existe pas déjà
    IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le type existe déjà";
	ELSE
		INSERT INTO dechet(type) VALUES(typeDechet);
	END IF$$

-- RETRIEVE

# Affiche le déchet d'identifiant idDechet
CREATE PROCEDURE PSGetDechet(IN idDechet SMALLINT)
	SELECT id, type FROM dechet 
    WHERE id = idDechet$$

# Affiche tous les déchets
CREATE PROCEDURE PL_Dechet()
	SELECT id, type FROM dechet$$

-- UPDATE

# Change le type de déchet d'identifiant idDechet
CREATE PROCEDURE PU_Dechet(IN idDechet SMALLINT, IN typeDechet VARCHAR(30))
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    # Alors
	THEN 
		# On vérifie que le type n'existe pas déjà
		IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE dechet
				SET type = typeDechet
			# du déchet d'identifiant idDechet         
			WHERE id = idDechet;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime le déchet d'identifiant idDechet
CREATE PROCEDURE PD_Dechet(IN idDechet SMALLINT)
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    THEN
        # Si l'identifiant du déchet est référencé dans la table traitement
        -- Test à supprimer si DELETE ON CASCADE
        -- idDechet (colonne dans traitement) = idDechet (entrée de la procédure)
		IF EXISTS(SELECT * FROM traitement WHERE idDechet = idDechet)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le déchet a son identifiant référencé dans la table traitement; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM dechet WHERE id = idDechet;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$
 
 # Supprime le déchet d'identifiant idDechet et toutes ses références (dans traitement)
 -- A utiliser avec précaution
CREATE PROCEDURE PD_DechetCascade(IN idDechet SMALLINT)
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    THEN
        # Suppression de toutes les dépendances dans traitement
		DELETE FROM traitement WHERE idDechet = idDechet;
        DELETE FROM dechet WHERE id = idDechet;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime le déchet selon le type
CREATE PROCEDURE PD_DechetByType(IN typeDechet VARCHAR(30))
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
    THEN
        # Si l'identifiant du déchet est référencé dans la table traitement
        -- Test à supprimer si DELETE ON CASCADE
        -- idDechet (colonne dans traitement) = id associé au type de déchet
		IF EXISTS(SELECT * FROM traitement WHERE idDechet = (SELECT id FROM dechet WHERE type = typeDechet))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le déchet a son identifiant référencé dans la table traitement; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM dechet WHERE type = typeDechet;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$    

# Supprime le déchet selon le type et toutes ses références (dans traitement)
 -- A utiliser avec précaution
CREATE PROCEDURE PD_DechetByTypeCascade(IN typeDechet VARCHAR(30))
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
    THEN
		# Suppression de toutes les dépendances dans traitement
        DELETE FROM traitement WHERE idDechet = (SELECT id FROM dechet WHERE type = typeDechet);
        # Suppression du déchet
        DELETE FROM dechet WHERE type = typeDechet;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$ 

-- BONUS

# Ajoute le déchet si il n'existe pas, le met à jour sinon
CREATE PROCEDURE PIU_Dechet(IN idDechet SMALLINT, IN typeDechet VARCHAR(30))
	# Si le type existe déjà
	IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce type existe déjà";
	ELSE
		# Si le déchet existe déjà
		IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
		THEN 	
			# On la met à jour
			UPDATE dechet
				SET type = typeDechet WHERE id = idDechet;
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO dechet VALUES(idDechet, typeDechet);
		END IF;
	END IF$$

/* 
CRUD TABLE decheterie
*/

-- CREATE 

# Ajoute une déchèterie avec toutes les informations
CREATE PROCEDURE PI_Decheterie(IN objectidDecheterie SMALLINT, IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN createurDecheterie VARCHAR(20), IN dateCreationDecheterie DATETIME, IN modificateurDecheterie VARCHAR(20), IN dateModificationDecheterie DATETIME, 
                                IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le globalid existe déjà
		IF EXISTS(SELECT * FROM decheterie WHERE globalid = globalIdDecheterie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# Si une déchèterie existe à cette adresse ou pour ces coordonnées
			IF EXISTS(SELECT * FROM decheterie WHERE adresse = adresseDecheterie) OR EXISTS(SELECT * FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
            ELSE
				# Si les temps d'enregistrement (création ou modification) sont dans le futur (et pas encore possibles)
                # ou si l'enregistrement a été créé après sa modification (impossible)
				IF dateCreationDecheterie > NOW() OR dateModificationDecheterie > NOW() OR dateCreationDecheterie > dateModificationDecheterie
                THEN
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = "La date indiquée de création ou de modification n'est pas possible";
				ELSE
					# On insère la nouvelle déchèterie dans la table
					INSERT INTO decheterie VALUES(objectidDecheterie, idDecheterie, dateInstallationDecheterie, adresseDecheterie, adresseComplementDecheterie, codeInseeDecheterie, observationsDecheterie, 
													createurDecheterie, dateCreationDecheterie, modificateurDecheterie, dateModificationDecheterie, globalIdDecheterie, _xDecheterie, _yDecheterie);
				END IF;
			END IF;
		END IF;
	END IF$$

# Ajoute une déchèterie avec les informations suffisantes
-- objectid est autoincrémenté
-- A la création de la déchèterie, le créateur est aussi le modificateur initial
-- Les dates de création et de modification correpondent à l'instant présent
CREATE PROCEDURE PI_DecheterieSimple(IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN createurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le globalid existe déjà
		IF EXISTS(SELECT * FROM decheterie WHERE globalid = globalIdDecheterie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# Si une déchèterie existe à cette adresse ou pour ces coordonnées
			IF EXISTS(SELECT * FROM decheterie WHERE adresse = adresseDecheterie) OR EXISTS(SELECT * FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
            ELSE
				# On insère la nouvelle déchèterie dans la table
				INSERT INTO decheterie(adresse, adresseComplement, codeInsee, observations, createur, dateCreation, globalid, _x, _y)
                VALUES(idDecheterie, dateInstallationDecheterie, adresseDecheterie, adresseComplementDecheterie, codeInseeDecheterie, observationsDecheterie, 
						createurDecheterie, NOW(), createurDecheterie, NOW(), globalIdDecheterie, _xDecheterie, _yDecheterie);
			END IF;
		END IF;
	END IF$$
                        
# Ajoute une déchèterie avec les informations nécessaires au minimum
CREATE PROCEDURE PI_DecheterieMin(IN codeInseeDecheterie CHAR(5), IN createurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	CALL PI_DecheterieSimple(NULL, NULL, NULL, NULL, codeInseeDecheterie, NULL, createurDecheterie, NOW(), createurDecheterie, NOW(), globalIdDecheterie, _xDecheterie, _yDecheterie);

-- RETRIEVE

# Affiche la déchèterie d'identifiant idDecheterie
CREATE PROCEDURE PSGetDecheterie(IN idDecheterie SMALLINT)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie 
    WHERE id = idDecheterie$$

# Affiche toutes les déchèteries
CREATE PROCEDURE PL_Decheterie()
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie$$

# Affiche les déchèteries selon la date d'installation
CREATE PROCEDURE PL_DecheterieByDateInstallation(IN dateInstallationDecheterie DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateInstallation = dateInstallationDecheterie$$

# Affiche les déchèteries installées après dateDebut et avant dateFin
CREATE PROCEDURE PL_DecheterieByDateInstallationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateInstallation BETWEEN dateDebut AND dateFin$$

# Affiche les déchèteries selon l'adresse
-- (qui contiennent adresseDecheterie dans leur adresse) 
CREATE PROCEDURE PL_DecheterieByAdresse(IN adresseDecheterie VARCHAR(50))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE adresse LIKE CONCAT('%', adresseDecheterie, '%')$$

# Affiche les déchèteries selon le code INSEE
CREATE PROCEDURE PL_DecheterieByCodeInsee(IN codeInseeDecheterie CHAR(5))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE codeInsee = codeInseeDecheterie$$

# Affiche les déchèteries enregistrées par createurDecheterie
CREATE PROCEDURE PL_DecheterieByCreateur(IN createurDecheterie VARCHAR(20))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE createur = createurDecheterie$$

# Affiche les déchèteries selon la date de création de la ligne
CREATE PROCEDURE PL_DecheterieByDateCreation(IN dateCreationDecheterie DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    # où la date de création se situe entre le jour indiqué (dateCreationDecheterie à minuit) et le jour suivant (minuit) pour comprendre la journée entière
    WHERE dateCreation BETWEEN dateCreationDecheterie AND DATE_ADD(dateCreationDecheterie, INTERVAL 1 DAY)$$

# Affiche les déchèteries dont les lignes ont été créées entre dateDebut et dateFin (inclus)
CREATE PROCEDURE PL_DecheterieByDateCreationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateInstallation BETWEEN dateDebut AND DATE_ADD(dateFin, INTERVAL 1 DAY)$$

# Affiche les déchèteries modifiées en dernier par modificateurDecheterie
CREATE PROCEDURE PL_DecheterieByModificateur(IN modificateurDecheterie VARCHAR(20))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE modificateur = modificateurDecheterie$$

# Affiche les déchèteries selon la dernière date de modification de la ligne
CREATE PROCEDURE PL_DecheterieByDateModification(IN dateModificationDecheterie DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    # où la date de création se situe entre le jour indiqué (dateCreationDecheterie à minuit) et le jour suivant (minuit) pour comprendre la journée entière
    WHERE dateModification BETWEEN dateModificationDecheterie AND DATE_ADD(dateModificationDecheterie, INTERVAL 1 DAY)$$

# Affiche les déchèteries dont les lignes ont été dernièrement modifiées entre dateDebut et dateFin (inclus)
CREATE PROCEDURE PL_DecheterieByDateModificationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateModification BETWEEN dateDebut AND DATE_ADD(dateFin, INTERVAL 1 DAY)$$    

# Affiche la déchèterie d'UUID globalid
CREATE PROCEDURE PL_DecheterieByGlobalid(IN globalidDecheterie VARCHAR(38))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE globalid = globalidDecheterie$$    
    
# Affiche la déchèterie selon les coordonnées
CREATE PROCEDURE PL_DecheterieByCoordonnees(IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE _x = _xDecheterie AND _y = _yDecheterie$$      

-- UPDATE

# Change le type de la catégorie d'identifiant idCategorie
CREATE PROCEDURE PU_Decheterie(IN objectidDecheterie SMALLINT, IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN createurDecheterie VARCHAR(20), IN dateCreationDecheterie DATETIME, IN modificateurDecheterie VARCHAR(20), IN dateModificationDecheterie DATETIME, 
                                IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# Si la déchèterie existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    # Alors
	THEN 
		# On vérifie que le globalid n'existe pas déjà (ou alors c'est celui de la ligne que l'on modifie)
		IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE categorie
				SET type = typeCategorie
			# de la catégorie d'identifiant idCategorie         
			WHERE id = idCategorie;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de modifier n'existe pas";
	END IF$$




	ELSE
		# Si le globalid existe déjà
		IF EXISTS(SELECT * FROM decheterie WHERE globalid = globalIdDecheterie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# Si une déchèterie existe à cette adresse ou pour ces coordonnées
			IF EXISTS(SELECT * FROM decheterie WHERE adresse = adresseDecheterie) OR EXISTS(SELECT * FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
            ELSE
				# Si les temps d'enregistrement (création ou modification) sont dans le futur (et pas encore possibles)
                # ou si l'enregistrement a été créé après sa modification (impossible)
				IF dateCreationDecheterie > NOW() OR dateModificationDecheterie > NOW() OR dateCreationDecheterie > dateModificationDecheterie
                THEN
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = "La date indiquée de création ou de modification n'est pas possible";
				ELSE
					# On insère la nouvelle déchèterie dans la table
					INSERT INTO decheterie VALUES(objectidDecheterie, idDecheterie, dateInstallationDecheterie, adresseDecheterie, adresseComplementDecheterie, codeInseeDecheterie, observationsDecheterie, 
													createurDecheterie, dateCreationDecheterie, modificateurDecheterie, dateModificationDecheterie, globalIdDecheterie, _xDecheterie, _yDecheterie);
				END IF;
			END IF;
		END IF;
	END IF$$






-- DELETE

# Supprime la déchèterie d'identifiant objectidDecheterie
CREATE PROCEDURE PD_Decheterie(IN objectidDecheterie SMALLINT)
	# Si la déchèterie existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    THEN
		# Si l'objectid de la déchèterie est référencée dans la table traitement
        -- Test à supprimer si DELETE ON CASCADE
        -- objectidDecheterie (colonne dans traitement) = objectidDecheterie (entrée de la procédure)
		IF EXISTS(SELECT * FROM traitement WHERE objectidDecheterie = objectidDecheterie)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La déchèterie a son identifiant référencé dans la table traitement; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM decheterie WHERE objectid = objectidDecheterie;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La déchèterie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la déchèterie d'identifiant objectidDecheterie et toutes ses références (dans traitement)
-- A utiliser avec précaution
CREATE PROCEDURE PD_DecheterieCascade(IN objectidDecheterie SMALLINT)
	# Si la déchèterie existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    THEN
		# Suppression de toutes les dépendances dans traitement
		DELETE FROM traitement WHERE objectidDecheterie = objectidDecheterie;
		DELETE FROM decheterie WHERE objectid = objectidDecheterie;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La déchèterie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la déchèterie selon 
zd





/* 
CRUD TABLE marque
*/

-- CREATE 

# Ajoute une marque avec un identifiant et un nom 
CREATE PROCEDURE PI_Marque(IN idMarque SMALLINT, IN nomMarque VARCHAR(15))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si la marque existe déjà
		IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce nom existe déjà";
		ELSE
			# On insère la nouvelle marque dans la table
			INSERT INTO marque VALUES(idMarque, nomMarque);
		END IF;
    # Fin du 1er IF    
	END IF$$

# Ajoute une marque avec juste son nom (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_MarqueSimple(IN nomMarque VARCHAR(15))
	# On vérifie que la marque n'existe pas déjà
    IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le nom existe déjà";
	ELSE
		INSERT INTO marque(nom) VALUES(nomMarque);
	END IF$$

-- RETRIEVE

# Affiche la marque d'identifiant idMarque
CREATE PROCEDURE PSGetMarque(IN idMarque SMALLINT)
	SELECT id, nom FROM marque 
    WHERE id = idMarque$$

# Affiche toutes les marques
CREATE PROCEDURE PL_Marque()
	SELECT id, nom FROM marque$$

-- UPDATE

# Change le nom de la marque d'identifiant idMarque
CREATE PROCEDURE PU_Marque(IN idMarque SMALLINT, IN nomMarque VARCHAR(15))
	# Si la marque existe
	IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    # Alors
	THEN 
		# On vérifie que le nom de la marque n'existe pas déjà
		IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le nom de la marque existe déjà";
		ELSE
		# On met à jour le nom
			UPDATE marque
				SET nom = nomMarque
			# de la marque d'identifiant idMarque         
			WHERE id = idMarque;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime la marque d'identifiant idMarque
CREATE PROCEDURE PD_Marque(IN idMarque SMALLINT)
	# Si la marque existe
	IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    THEN
		# Si l'identifiant de la marque est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idMarque (colonne dans collecteur) = idMarque (entrée de la procédure)
		IF EXISTS(SELECT * FROM collecteur WHERE idMarque = idMarque)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La marque a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM marque WHERE id = idMarque;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$
    
   
# Supprime la marque d'identifiant idMarque et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_MarqueCascade(IN idMarque SMALLINT)
	# Si la marque existe
	IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    THEN
		# Réinitialisation à NULL des références à cette marque dans collecteur
		UPDATE collecteur 
			SET idMarque = NULL
        WHERE idMarque = idMarque;
        # Suppresion de la catégorie
		DELETE FROM marque WHERE id = idMarque;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$   
    
# Supprime la marque selon le nom
CREATE PROCEDURE PD_MarqueByNom(IN nomMarque VARCHAR(15))
	# Si le nom existe
	IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
    THEN
		# Si l'identifiant associé au nom de la marque est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idMarque (colonne dans collecteur) = id associé au type de la catégorie
		IF EXISTS(SELECT * FROM collecteur WHERE idMarque = (SELECT id FROM marque WHERE nom = nomMarque))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La marque a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM marque WHERE nom = nomMarque;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la marque selon le nom et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_MarqueByNomCascade(IN nomMarque VARCHAR(15))
	# Si le nom existe
	IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
    THEN
		# Réinitialisation à NULL des références à cette marque dans collecteur
		UPDATE collecteur
			SET idMarque = NULL
        WHERE idMarque = (SELECT id FROM marque WHERE nom = nomMarque);
		DELETE FROM marque WHERE nom = nomMarque;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$   
    
-- BONUS

# Ajoute la marque si elle n'existe pas, la met à jour sinon
CREATE PROCEDURE PIU_Marque(IN idMarque SMALLINT, IN nomMarque VARCHAR(15))
	# Si le nom existe déjà
	IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce nom existe déjà";
	ELSE
		# Si la marque existe déjà
		IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
		THEN 	
			# On la met à jour
			UPDATE marque
				SET nom = nomMarque WHERE id = idMarque;
		ELSE
			# On insère la nouvelle marque dans la table
			INSERT INTO marque VALUES(idMarque, nomMarque);
		END IF;
	END IF$$

/* 
CRUD TABLE traitement
*/

-- CREATE

# Ajoute un traitement avec les identifiants de déchèterie et de déchet 
CREATE PROCEDURE PI_Traitement(IN objectidDecheterie SMALLINT, IN idDechet SMALLINT)
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    THEN
		IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
        THEN
			INSERT INTO traitement VALUES(objectidDecheterie, idDechet);
		ELSE
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "L'identifiant de déchet n'existe pas dans la table déchet";
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "L'identifiant de déchèterie n'existe pas dans la table déchèterie";
	END IF;
    
-- RETRIEVE

# Affiche tous les traitements
CREATE PROCEDURE PL_Traitement()
	SELECT objectidDecheterie, idDechet FROM traitement$$    

# Affiche les traitements selon l'identifiant de déchèterie
CREATE PROCEDURE PL_TraitementByObjectidDecheterie(IN objectidDecheterie SMALLINT)
	SELECT objectidDecheterie, idDechet FROM traitement WHERE objectidDecheterie = objectidDecheterie$$
    
# Affiche les traitements selon l'identifiant de déchet
CREATE PROCEDURE PL_TraitementByIdDecheterie(IN idDechet SMALLINT)
	SELECT objectidDecheterie, idDechet FROM traitement WHERE idDechet = idDechet$$
    
-- UPDATE (à éviter car 2 clés primaires)

-- DELETE

# Supprime le traitement d'identifiant (objectidDecheterie, idDechet)
CREATE PROCEDURE PD_Traitement(IN objectidDecheterie SMALLINT, IN idDechet SMALLINT)
	# Si le traitement existe
	IF EXISTS(SELECT * FROM traitement WHERE objectidDecheterie = objectidDecheterie AND idDechet = idDechet)
    THEN
		DELETE FROM traitement WHERE objectidDecheterie = objectidDecheterie AND idDechet = idDechet;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le traitement que vous essayez de supprimer n'existe pas";
	END IF$$

/* 
CRUD TABLE tri
*/

-- CREATE 

# Ajoute un tri avec un identifiant et un type 
CREATE PROCEDURE PI_Tri(IN idTri SMALLINT, IN typeTri VARCHAR(30))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM tri WHERE id = idTri)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le type existe déjà
		IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce tri existe déjà";
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO tri VALUES(idtri, typeTri);
		END IF;
	END IF$$

# Ajoute un tri avec juste son type (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_TriSimple(IN typeTri VARCHAR(30))
	# On vérifie que le type n'existe pas déjà
    IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le type existe déjà";
	ELSE
		INSERT INTO tri(type) VALUES(typeTri);
	END IF$$

-- RETRIEVE

# Affiche le tri d'identifiant idTri
CREATE PROCEDURE PSGetTri(IN idTri SMALLINT)
	SELECT id, type FROM tri 
    WHERE id = idTri$$

# Affiche tous les tris
CREATE PROCEDURE PL_Tri()
	SELECT id, type FROM tri$$

-- UPDATE

# Change le type de tri d'identifiant idCategorie
CREATE PROCEDURE PU_Tri(IN idTri SMALLINT, IN typeTri VARCHAR(30))
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE id = idTri)
    # Alors
	THEN 
		# On vérifie que le type n'existe pas déjà
		IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE tri
				SET type = typeTri
			# du tri d'identifiant idTri         
			WHERE id = idTri;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime le tri d'identifiant idTri
CREATE PROCEDURE PD_Tri(IN idTri SMALLINT)
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE id = idtri)
    THEN
		# Si l'identifiant du tri est référencé dans la table collecteur
        -- Test à supprimer si DELETE ON CASCADE
        -- idTri (colonne dans collecteur) = idTri (entrée de la procédure)
		IF EXISTS(SELECT * FROM collecteur WHERE idTri = idTri)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le tri a son identifiant référencé dans la table collecteur; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM tri WHERE id = idTri;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$
 
 # Supprime le tri d'identifiant idTri et toutes ses références (dans collecteur)
-- A utiliser avec précaution
CREATE PROCEDURE PD_TriCascade(IN idTri SMALLINT)
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE id = idtri)
    THEN
		# Suppression de toutes les dépendances dans collecteur
		DELETE FROM collecteur WHERE idTri = idTri;
        # Suppresion du tri
		DELETE FROM tri WHERE id = idtri;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$   
    
# Supprime le tri selon le type
CREATE PROCEDURE PD_TriByType(IN typeTri VARCHAR(30))
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
    THEN
    
		# Si l'identifiant du tri est référencé dans la table collecteur
        -- Test à supprimer si DELETE ON CASCADE
        -- idTri (colonne dans collecteur) = id associé au type de la catégorie
		IF EXISTS(SELECT * FROM collecteur WHERE idTri = (SELECT id FROM tri WHERE type = typeTri))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le tri a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM tri WHERE type = typeTri;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$
    
 # Supprime le tri selon le type et et toutes ses références (dans collecteur)
 -- A utiliser avec précaution
CREATE PROCEDURE PD_TriByTypeCascade(IN typeTri VARCHAR(30))
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
    THEN
		# Suppression de toutes les dépendances dans collecteur
		DELETE FROM collecteur WHERE idTri = (SELECT id FROM tri WHERE type = typeTri);
        # Suppresion du tri
		DELETE FROM tri WHERE type = typeTri;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$   

-- BONUS

# Ajoute le tri si il n'existe pas, le met à jour sinon
CREATE PROCEDURE PIU_Tri(IN idTri SMALLINT, IN typeTri VARCHAR(30))
	# Si le type existe déjà
	IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce type existe déjà";
	ELSE
		# Si le tri existe déjà
		IF EXISTS(SELECT * FROM tri WHERE id = idTri)
		THEN 	
			# On le met à jour
			UPDATE tri
				SET type = typeTri WHERE id = idTri;
		ELSE
			# On insère le nouveau tri dans la table
			INSERT INTO tri VALUES(idTri, typeTri);
		END IF;
	END IF$$                                    