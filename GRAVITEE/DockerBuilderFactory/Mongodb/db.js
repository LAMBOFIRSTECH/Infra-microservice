// Fonction pour créer un utilisateur avec les rôles appropriés
function createUserInDB(dbName, user, pwd, roles) {
    const db = db.getSiblingDB(dbName);
    try {
        db.createUser({
            user: user,
            pwd: pwd,
            roles: roles
        });
        print(`Utilisateur '${user}' créé dans la base de données '${dbName}'.`);
    } catch (e) {
        print(`Erreur lors de la création de '${user}' dans '${dbName}': ` + e);
    }
}

// Fonction pour créer un rôle spécifique dans la base de données
function createRoleInDB(dbName, roleName, privileges) {
    const db = db.getSiblingDB(dbName);
    try {
        db.createRole({
            role: roleName,
            privileges: privileges,
            roles: []
        });
        print(`Rôle '${roleName}' créé dans '${dbName}'.`);
    } catch (e) {
        print(`Rôle '${roleName}' déjà existant ou erreur dans '${dbName}': ` + e);
    }
}

// Définir les rôles
const userPasswordManagerPrivileges = [
    {
        resource: { db: "gravitee_db", collection: "" },
        actions: ["changePassword", "updateUser", "grantRolesToUser"]
    }
];

// Définir les rôles des utilisateurs
const vaultAdminRoles = [
    { role: "userAdmin", db: "gravitee_db" },
    { role: "userPasswordManager", db: "gravitee_db" },
    { role: "readWrite", db: "gravitee_db" },
    { role: "userAdmin", db: "gravitee_analytics" },
    { role: "userPasswordManager", db: "gravitee_analytics" },
    { role: "readWrite", db: "gravitee_analytics" }
];

const graviteeServiceRoles = [
    { role: "readWrite", db: "gravitee_db" },
    { role: "readWrite", db: "gravitee_analytics" }
];

// Créer le rôle 'userPasswordManager' dans les deux bases si nécessaire
createRoleInDB("gravitee_db", "userPasswordManager", userPasswordManagerPrivileges);
createRoleInDB("gravitee_analytics", "userPasswordManager", userPasswordManagerPrivileges);

// Créer les utilisateurs dans les deux bases de données
createUserInDB("gravitee_db", "vault_admin", "1234", vaultAdminRoles);
createUserInDB("gravitee_analytics", "vault_admin", "1234", vaultAdminRoles);

createUserInDB("gravitee_db", "gravitee_service", "password", graviteeServiceRoles);
createUserInDB("gravitee_analytics", "gravitee_service", "password", graviteeServiceRoles);
