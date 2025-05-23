const fs = require('fs').promises;
const path = require('path');

module.exports = {
    async getProfiles() {
        try {
            const profilesDir = path.join(__dirname, '../../config/profiles');
            await fs.mkdir(profilesDir, { recursive: true });
            const files = await fs.readdir(profilesDir);
            return files.map(file => file.replace('.json', ''));
        } catch (err) {
            console.error('Error listing profiles:', err);
            return [];
        }
    },

    async saveProfile(name, config) {
        try {
            const profilePath = path.join(__dirname, '../../config/profiles', `${name}.json`);
            await fs.writeFile(profilePath, JSON.stringify(config, null, 2));
        } catch (err) {
            console.error('Error saving profile:', err);
            throw err;
        }
    },

    async loadProfile(name) {
        try {
            const profilePath = path.join(__dirname, '../../config/profiles', `${name}.json`);
            const data = await fs.readFile(profilePath, 'utf8');
            return JSON.parse(data);
        } catch (err) {
            console.error('Error loading profile:', err);
            return null;
        }
    }
};
